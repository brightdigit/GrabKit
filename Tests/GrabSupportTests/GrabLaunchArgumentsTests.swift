//
//  GrabLaunchArgumentsTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import GrabSupport
import Testing

@Suite("Launch arguments")
internal struct GrabLaunchArgumentsTests {
  private static let arguments = GrabLaunchArguments(prefix: "TC")

  @Test("Flags and the environment key come from the prefix")
  internal func names() {
    #expect(Self.arguments.screenshots == "-TCScreenshots")
    #expect(Self.arguments.appearance == "-TCAppearance")
    #expect(Self.arguments.appearancesEnvironmentKey == "TC_SCREENSHOT_APPEARANCES")
  }

  @Test("Every flag carries a value, then the screen's extras")
  internal func launchArguments() {
    #expect(
      Self.arguments.launchArguments(appearance: .dark, extra: ["-TCStage", "YES"]) == [
        "-TCScreenshots", "YES", "-TCAppearance", "dark",
        "-ApplePersistenceIgnoreState", "YES", "-TCStage", "YES",
      ]
    )
  }

  @Test("The launch arguments round-trip")
  internal func roundTrip() {
    for appearance in GrabAppearance.allCases {
      let launch = Self.arguments.launchArguments(appearance: appearance)
      #expect(Self.arguments.requestsScreenshotMode(launch))
      #expect(Self.arguments.appearance(in: launch) == appearance)
    }
  }

  @Test(
    "Screenshot mode needs the flag followed by YES",
    arguments: [
      ([], false),
      (["-TCScreenshots"], false),
      (["-TCScreenshots", "NO"], false),
      (["-TCScreenshots", "YES"], true),
      (["-TCScreenshots", "NO", "-TCScreenshots", "YES"], true),
      (["-OtherScreenshots", "YES"], false),
    ] as [([String], Bool)]
  )
  internal func requestsScreenshotMode(arguments: [String], expected: Bool) {
    #expect(Self.arguments.requestsScreenshotMode(arguments) == expected)
  }

  @Test("An unknown appearance follows the system")
  internal func unknownAppearance() {
    #expect(Self.arguments.appearance(in: ["-TCAppearance", "sepia"]) == nil)
    #expect(Self.arguments.appearance(in: ["-TCAppearance"]) == nil)
  }
}
