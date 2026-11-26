//
//  GrabCropTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import Testing

@testable import GrabTesting

#if canImport(CoreGraphics)
  import CoreGraphics
#else
  import Foundation
#endif

/// The pixel arithmetic behind a crop and the light-or-dark threshold: no
/// CoreGraphics drawing, so they run on every platform, Linux included.
@Suite("Screenshot crop and luminance")
internal struct GrabCropTests {
  @Test("The scale is pixels over points")
  internal func scale() {
    #expect(GrabCrop.scale(pixelWidth: 2_880, pointWidth: 1_440) == 2)
    #expect(GrabCrop.scale(pixelWidth: 0, pointWidth: 1_440) == nil)
    #expect(GrabCrop.scale(pixelWidth: 2_880, pointWidth: 0) == nil)
  }

  @Test("Frames are unioned, scaled, rounded out and clipped")
  internal func pixelRect() {
    let rect = GrabCrop.pixelRect(
      unionOf: [
        CGRect(x: 10, y: 20, width: 100, height: 50),
        CGRect(x: 0.5, y: 25, width: 20, height: 100),
      ],
      scale: 2,
      pixelSize: CGSize(width: 200, height: 200)
    )
    #expect(rect == CGRect(x: 1, y: 40, width: 199, height: 160))
  }

  @Test("No frames, or frames off the image, give no rectangle")
  internal func pixelRectMisses() {
    let size = CGSize(width: 100, height: 100)
    #expect(GrabCrop.pixelRect(unionOf: [], scale: 2, pixelSize: size) == nil)
    #expect(
      GrabCrop.pixelRect(
        unionOf: [CGRect(x: 500, y: 500, width: 10, height: 10)],
        scale: 2,
        pixelSize: size
      ) == nil
    )
  }

  @Test("Luminance at or above 0.5 is light")
  internal func threshold() {
    #expect(GrabAppearanceDetector.appearance(averageLuminance: 0.5) == .light)
    #expect(GrabAppearanceDetector.appearance(averageLuminance: 0.49) == .dark)
  }

  @Test("Rec. 709 weights: pure green is brighter than pure red or blue")
  internal func rec709() {
    let red = GrabAppearanceDetector.luminance(ofRGBX: [255, 0, 0, 0])
    let green = GrabAppearanceDetector.luminance(ofRGBX: [0, 255, 0, 0])
    let blue = GrabAppearanceDetector.luminance(ofRGBX: [0, 0, 255, 0])
    #expect(abs(red - 0.2126) < 0.0001)
    #expect(abs(green - 0.7152) < 0.0001)
    #expect(abs(blue - 0.0722) < 0.0001)
  }
}
