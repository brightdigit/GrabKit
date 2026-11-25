//
//  Platform.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// What the platform running GrabSupport's tests offers, for
/// `.enabled(if:)` traits.
internal enum Platform {
  /// AppKit's `NSAppearance`, behind `GrabAppearance.appearanceName` and
  /// `apply()`: macOS only, not Mac Catalyst.
  #if os(macOS)
    internal static let isAppKitAvailable = true
  #else
    internal static let isAppKitAvailable = false
  #endif

  /// UIKit's `UIUserInterfaceStyle`, behind
  /// `GrabAppearance.userInterfaceStyle`: iOS, Mac Catalyst, tvOS and
  /// visionOS.
  #if canImport(UIKit) && !os(watchOS)
    internal static let isUIKitAvailable = true
  #else
    internal static let isUIKitAvailable = false
  #endif
}
