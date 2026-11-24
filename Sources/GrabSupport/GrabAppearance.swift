//
//  GrabAppearance.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import AppKit

/// The appearance a screenshot is taken in.
///
/// Passed to the app as `-<Prefix>Appearance light|dark` and used in file
/// names (`02-main-dark.png`).
public enum GrabAppearance: String, CaseIterable, Sendable, Hashable {
  /// Aqua.
  case light
  /// Dark Aqua.
  case dark

  /// The AppKit appearance: `.aqua` or `.darkAqua`.
  public var appearanceName: NSAppearance.Name {
    switch self {
    case .light:
      .aqua
    case .dark:
      .darkAqua
    }
  }

  /// The appearances listed in `value` ("light dark", "dark", "light,dark"),
  /// in order and without repeats, ignoring unknown names; every appearance
  /// when it names none.
  ///
  /// - Parameter value: An environment variable's value, such as the test
  ///   runner's `<PREFIX>_SCREENSHOT_APPEARANCES`.
  /// - Returns: The appearances to capture.
  public static func requested(from value: String?) -> [Self] {
    var result: [Self] = []
    for name in (value ?? "").split(whereSeparator: { $0 == " " || $0 == "," }) {
      guard let appearance = Self(rawValue: name.lowercased()),
        !result.contains(appearance)
      else {
        continue
      }
      result.append(appearance)
    }
    return result.isEmpty ? allCases : result
  }

  /// Sets `NSApp.appearance`, before any window opens, so the app draws in
  /// this appearance whatever the Mac's is.
  @MainActor
  public func apply() {
    NSApplication.shared.appearance = NSAppearance(named: appearanceName)
  }
}
