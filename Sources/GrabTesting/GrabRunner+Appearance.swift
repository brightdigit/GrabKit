//
//  GrabRunner+Appearance.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if canImport(XCUIAutomation)
  import Foundation
  import GrabSupport
  import XCTest

  extension GrabRunner {
    /// The Mac's appearance before this test run's first capture, which
    /// every capture restores.
    ///
    /// Read once per run, before any switch. `XCUIDevice` can report
    /// `.unspecified`, and setting that changes nothing, which once left a
    /// Mac in Dark after a run, so then the global `AppleInterfaceStyle`
    /// default decides.
    internal static let originalAppearance: XCUIDevice.Appearance = {
      #if os(watchOS)
        // watchOS UI tests can't read or switch the watch's appearance.
        return .unspecified
      #else
        let reported = XCUIDevice.shared.appearance
        guard reported == .unspecified else {
          return reported
        }
        let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        return style == "Dark" ? .dark : .light
      #endif
    }()

    /// Switches the device's appearance; does nothing on watchOS, whose UI
    /// tests can't.
    internal static func setDeviceAppearance(_ appearance: XCUIDevice.Appearance) {
      #if !os(watchOS)
        XCUIDevice.shared.appearance = appearance
      #endif
    }

    internal static func deviceAppearance(
      _ appearance: GrabAppearance
    ) -> XCUIDevice.Appearance {
      appearance == .dark ? .dark : .light
    }
  }
#endif
