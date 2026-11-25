//
//  GrabAppearance.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if os(macOS)
  public import AppKit
#elseif canImport(UIKit) && !os(watchOS)
  public import UIKit
#endif

/// The appearance a screenshot is taken in.
///
/// Passed to the app as `-<Prefix>Appearance light|dark` and used in file
/// names (`02-main-dark.png`).
public enum GrabAppearance: String, CaseIterable, Sendable, Hashable {
  /// Aqua.
  case light
  /// Dark Aqua.
  case dark

  #if os(macOS)
    /// The AppKit appearance: `.aqua` or `.darkAqua`.
    public var appearanceName: NSAppearance.Name {
      switch self {
      case .light:
        .aqua
      case .dark:
        .darkAqua
      }
    }
  #elseif canImport(UIKit) && !os(watchOS)
    /// The UIKit interface style: `.light` or `.dark`, for a window's
    /// `overrideUserInterfaceStyle`.
    public var userInterfaceStyle: UIUserInterfaceStyle {
      switch self {
      case .light:
        .light
      case .dark:
        .dark
      }
    }
  #endif

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

  #if os(macOS)
    /// Sets `NSApp.appearance`, before any window opens, so the app draws in
    /// this appearance whatever the Mac's is.
    @MainActor
    public func apply() {
      NSApplication.shared.appearance = NSAppearance(named: appearanceName)
    }
  #elseif canImport(UIKit) && !os(watchOS)
    /// Sets `window.overrideUserInterfaceStyle`, so the window draws in this
    /// appearance whatever the device's is.
    ///
    /// - Parameter window: The window, usually as its scene connects.
    @MainActor
    public func apply(to window: UIWindow) {
      window.overrideUserInterfaceStyle = userInterfaceStyle
    }
  #endif
}
