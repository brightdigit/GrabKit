//
//  GrabLaunchDecisionTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import GrabSupport
import Testing

@Suite("Fail-closed launch decision")
internal struct GrabLaunchDecisionTests {
  private static let launchArguments = GrabLaunchArguments(prefix: "TC")
  private static let screenshotsID = "com.example.App.Screenshots"
  private static let requested = ["App", "-TCScreenshots", "YES"]

  private static func decide(_ arguments: [String], _ bundleID: String?)
    -> GrabLaunchDecision
  {
    GrabLaunchDecision(
      arguments: arguments,
      bundleIdentifier: bundleID,
      launchArguments: launchArguments
    )
  }

  @Test("The .Screenshots bundle ID with the flag runs in screenshot mode")
  internal func screenshots() {
    #expect(Self.decide(Self.requested, Self.screenshotsID) == .screenshots)
    #expect(Self.decide(Self.requested, Self.screenshotsID).startsScreenshotMode())
  }

  @Test("The .Screenshots bundle ID without the flag quits")
  internal func refuse() {
    #expect(Self.decide(["App"], Self.screenshotsID) == .refuse)
    #expect(Self.decide(["App", "-TCScreenshots", "NO"], Self.screenshotsID) == .refuse)
  }

  @Test("Any other bundle ID runs live and ignores the flag")
  internal func live() {
    #expect(Self.decide(Self.requested, "com.example.App") == .live)
    #expect(Self.decide(["App"], "com.example.App") == .live)
    #expect(Self.decide(Self.requested, nil) == .live)
    #expect(!Self.decide(Self.requested, "com.example.App").startsScreenshotMode())
  }
}
