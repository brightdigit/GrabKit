//
//  GrabLaunchDecision.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import Foundation
import OSLog

/// Whether a Screenshots build may run in screenshot mode.
///
/// Only the app's `Main.swift` asks, under `#if SCREENSHOTS`, before it
/// touches any data. A Screenshots build either runs on demo data or quits:
/// it never falls back to the user's real data.
public enum GrabLaunchDecision: Equatable, Sendable {
  /// Run in screenshot mode on demo data.
  case screenshots
  /// Quit: the launch didn't ask for screenshot mode.
  case refuseMissingArgument
  /// Quit: the build doesn't carry a `.Screenshots` bundle ID.
  case refuseBundleIdentifier

  /// Decides a launch.
  ///
  /// - Parameters:
  ///   - arguments: The launch arguments.
  ///   - bundleIdentifier: The running app's bundle ID.
  ///   - launchArguments: The app's screenshot arguments.
  public init(
    arguments: [String] = ProcessInfo.processInfo.arguments,
    bundleIdentifier: String? = Bundle.main.bundleIdentifier,
    launchArguments: GrabLaunchArguments
  ) {
    guard bundleIdentifier?.isGrabBundleIdentifier == true else {
      self = .refuseBundleIdentifier
      return
    }
    self =
      launchArguments.requestsScreenshotMode(arguments)
      ? .screenshots : .refuseMissingArgument
  }

  /// Returns if this launch may run in screenshot mode; otherwise logs a
  /// fault and quits.
  ///
  /// It quits with `exit`, not a trap: a crash leaves a "quit unexpectedly"
  /// dialog on screen, and in the next screenshots.
  public func requireScreenshotMode() {
    guard self != .screenshots else {
      return
    }
    let logger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "GrabKit",
      category: "Screenshots"
    )
    switch self {
    case .refuseBundleIdentifier:
      logger.fault("A Screenshots build needs a bundle ID ending in .Screenshots.")
    default:
      logger.fault("A Screenshots build runs only in screenshot mode.")
    }
    exit(EXIT_FAILURE)
  }
}
