//
//  GrabAppearanceTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import GrabSupport
import Testing

#if os(macOS)
  import AppKit
#elseif canImport(UIKit) && !os(watchOS)
  import UIKit
#endif

@Suite("Appearances")
internal struct GrabAppearanceTests {
  @Test(
    "Requested appearances come from the environment value",
    arguments: [
      (nil, [GrabAppearance.light, .dark]),
      ("", [.light, .dark]),
      ("dark", [.dark]),
      ("dark light", [.dark, .light]),
      ("light,dark,light", [.light, .dark]),
      ("DARK", [.dark]),
      ("sepia", [.light, .dark]),
    ] as [(String?, [GrabAppearance])]
  )
  internal func requested(value: String?, expected: [GrabAppearance]) {
    #expect(GrabAppearance.requested(from: value) == expected)
  }

  #if os(macOS)
    @Test("Light is Aqua and dark is Dark Aqua", .enabled(if: Platform.isAppKitAvailable))
    internal func appearanceNames() {
      #expect(GrabAppearance.light.appearanceName == .aqua)
      #expect(GrabAppearance.dark.appearanceName == .darkAqua)
    }
  #endif

  #if canImport(UIKit) && !os(watchOS)
    @Test(
      "Light and dark are UIKit's light and dark interface styles",
      .enabled(if: Platform.isUIKitAvailable)
    )
    internal func userInterfaceStyles() {
      #expect(GrabAppearance.light.userInterfaceStyle == .light)
      #expect(GrabAppearance.dark.userInterfaceStyle == .dark)
    }

    @Test(
      "Applying an appearance overrides a window's interface style",
      .enabled(if: Platform.isUIKitAvailable)
    )
    @MainActor
    internal func applyToWindow() {
      let window = UIWindow(frame: .zero)
      GrabAppearance.dark.apply(to: window)
      #expect(window.overrideUserInterfaceStyle == .dark)
      GrabAppearance.light.apply(to: window)
      #expect(window.overrideUserInterfaceStyle == .light)
    }
  #endif

  @Test("Only a .Screenshots suffix marks a Screenshots build")
  internal func bundleIdentifier() {
    #expect("com.example.App.Screenshots".isGrabBundleIdentifier)
    #expect(!"com.example.App".isGrabBundleIdentifier)
    #expect(!"com.example.ScreenshotsApp".isGrabBundleIdentifier)
  }
}
