//
//  GrabAppearanceTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import AppKit
import GrabSupport
import Testing

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

  @Test("Light is Aqua and dark is Dark Aqua")
  internal func appearanceNames() {
    #expect(GrabAppearance.light.appearanceName == .aqua)
    #expect(GrabAppearance.dark.appearanceName == .darkAqua)
  }

  @Test("Only a .Screenshots suffix marks a Screenshots build")
  internal func bundleIdentifier() {
    #expect("com.example.App.Screenshots".isGrabBundleIdentifier)
    #expect(!"com.example.App".isGrabBundleIdentifier)
    #expect(!"com.example.ScreenshotsApp".isGrabBundleIdentifier)
  }
}
