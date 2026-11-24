//
//  GrabLaunchDecision.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import Foundation
import OSLog

/// How a launch runs: live, in screenshot mode, or not at all.
///
/// Every launch decides at runtime, before it touches any data; there is no
/// compile gate. Only a Screenshots build (a `.Screenshots` bundle ID, with
/// its own container and defaults) can run on demo data, and it never falls
/// back to live: it either runs in screenshot mode or quits. Any other build
/// runs live and ignores the screenshot flag.
public enum GrabLaunchDecision: Equatable, Sendable {
  /// Run normally, on the user's real data.
  case live
  /// Run in screenshot mode on demo data.
  case screenshots
  /// Quit: a Screenshots build launched without screenshot mode.
  case refuse

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
      self = .live
      return
    }
    self = launchArguments.requestsScreenshotMode(arguments) ? .screenshots : .refuse
  }

  /// Whether this launch runs in screenshot mode; quits first if it must
  /// refuse.
  ///
  /// Call it before the app reads any data. It quits with `exit`, not a
  /// trap: a crash leaves a "quit unexpectedly" dialog on screen, and in the
  /// next screenshots.
  ///
  /// - Returns: `true` for screenshot mode, `false` to run live.
  public func startsScreenshotMode() -> Bool {
    switch self {
    case .live:
      return false
    case .screenshots:
      return true
    case .refuse:
      let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "GrabKit",
        category: "Screenshots"
      )
      logger.fault("A Screenshots build runs only in screenshot mode.")
      exit(EXIT_FAILURE)
    }
  }
}
