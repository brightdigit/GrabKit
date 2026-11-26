//
//  GrabLaunchArguments.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// One app's screenshot launch arguments: the contract between its UI tests,
/// which write them, and the app, which reads them.
///
/// Every flag takes a value (`-TCScreenshots YES`). AppKit reads launch
/// arguments as `-Key value` pairs, so a bare flag would swallow the next
/// argument.
public struct GrabLaunchArguments: Sendable, Hashable {
  /// The value that turns a flag on.
  public static let enabledValue = "YES"

  /// The prefix of the app's flags: `TC` gives `-TCScreenshots`.
  public let prefix: String

  /// Turns screenshot mode on: `-<prefix>Screenshots YES`.
  public var screenshots: String {
    "-\(prefix)Screenshots"
  }

  /// Sets the app's appearance: `-<prefix>Appearance light|dark`.
  public var appearance: String {
    "-\(prefix)Appearance"
  }

  /// The test runner's environment variable listing the appearances to
  /// capture: `<PREFIX>_SCREENSHOT_APPEARANCES`.
  ///
  /// `make screenshots` sets it through `TEST_RUNNER_<PREFIX>_SCREENSHOT_…`,
  /// since xcodebuild passes `TEST_RUNNER_`-prefixed variables to the runner
  /// without the prefix.
  public var appearancesEnvironmentKey: String {
    "\(prefix.uppercased())_SCREENSHOT_APPEARANCES"
  }

  /// Creates an app's arguments.
  ///
  /// - Parameter prefix: The prefix of the app's flags, such as `TC`.
  public init(prefix: String) {
    self.prefix = prefix
  }

  /// The value after the last `flag` in `arguments`, if there is one.
  ///
  /// - Parameters:
  ///   - flag: The flag, including its leading `-`.
  ///   - arguments: The launch arguments.
  /// - Returns: The flag's value.
  public static func value(after flag: String, in arguments: [String]) -> String? {
    guard let index = arguments.lastIndex(of: flag) else {
      return nil
    }
    let next = arguments.index(after: index)
    return arguments.indices.contains(next) ? arguments[next] : nil
  }

  /// The arguments one screenshot launch uses: screenshot mode, the
  /// appearance, no restored windows, then `extra`.
  ///
  /// - Parameters:
  ///   - appearance: The appearance to launch in.
  ///   - extra: More `-Key value` pairs for this screen.
  /// - Returns: The launch arguments.
  public func launchArguments(
    appearance: GrabAppearance,
    extra: [String] = []
  ) -> [String] {
    [
      screenshots, Self.enabledValue,
      self.appearance, appearance.rawValue,
      "-ApplePersistenceIgnoreState", "YES",
    ] + extra
  }

  /// Whether `arguments` turn screenshot mode on.
  ///
  /// - Parameter arguments: The launch arguments.
  /// - Returns: `true` for `-<prefix>Screenshots YES`.
  public func requestsScreenshotMode(_ arguments: [String]) -> Bool {
    Self.value(after: screenshots, in: arguments) == Self.enabledValue
  }

  /// The appearance `arguments` ask for, if they name a valid one.
  ///
  /// - Parameter arguments: The launch arguments.
  /// - Returns: The appearance, or `nil` to follow the system.
  public func appearance(in arguments: [String]) -> GrabAppearance? {
    Self.value(after: appearance, in: arguments).flatMap(GrabAppearance.init(rawValue:))
  }
}
