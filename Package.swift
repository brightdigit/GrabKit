// swift-tools-version: 6.4
//
//  Package.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import PackageDescription

// swiftlint:disable:next explicit_acl explicit_top_level_acl no_global_declarations
let package = Package(
  name: "GrabKit",
  // macOS 27 is the screenshot tooling's home. The others are the lowest
  // the code builds for: grab-export's URL file-path API (`URL(filePath:)`,
  // `path(percentEncoded:)`) needs iOS 16, watchOS 9 and tvOS 16. AppKit,
  // XCUITest-only and ImageIO code is behind `#if`, so every target builds on
  // every platform, Linux included.
  platforms: [
    .macOS(.v27),
    .iOS(.v16),
    .watchOS(.v9),
    .tvOS(.v16),
    .visionOS(.v1),
    .macCatalyst(.v16),
  ],
  products: [
    // The app side of screenshot mode: launch arguments, appearance, the
    // fail-closed launch decision and the fixed window size. Linked only by
    // an app's demo target, which the app asks at every launch.
    .library(name: "GrabSupport", targets: ["GrabSupport"]),
    // The UI test side: drive, capture, crop, detect light or dark, name
    // and attach.
    .library(name: "GrabTesting", targets: ["GrabTesting"]),
    // Exports a run's PNG attachments from its .xcresult.
    .executable(name: "grab-export", targets: ["grab-export"]),
  ],
  targets: [
    .target(name: "GrabSupport"),
    .target(name: "GrabTesting", dependencies: ["GrabSupport"]),
    .target(name: "GrabExportCore"),
    .executableTarget(name: "grab-export", dependencies: ["GrabExportCore"]),
    .testTarget(name: "GrabSupportTests", dependencies: ["GrabSupport"]),
    .testTarget(
      name: "GrabTestingTests",
      dependencies: ["GrabTesting", "GrabSupport"],
      resources: [.copy("Fixtures")]
    ),
    .testTarget(name: "GrabExportCoreTests", dependencies: ["GrabExportCore"]),
  ]
)
