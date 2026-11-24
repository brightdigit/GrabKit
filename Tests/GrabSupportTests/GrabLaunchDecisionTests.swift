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
  }

  @Test("The .Screenshots bundle ID without the flag quits")
  internal func missingArgument() {
    #expect(Self.decide(["App"], Self.screenshotsID) == .refuseMissingArgument)
    #expect(
      Self.decide(["App", "-TCScreenshots", "NO"], Self.screenshotsID)
        == .refuseMissingArgument
    )
  }

  @Test("Any other bundle ID quits, flag or not")
  internal func wrongBundleIdentifier() {
    #expect(Self.decide(Self.requested, "com.example.App") == .refuseBundleIdentifier)
    #expect(Self.decide(["App"], "com.example.App") == .refuseBundleIdentifier)
    #expect(Self.decide(Self.requested, nil) == .refuseBundleIdentifier)
  }
}
