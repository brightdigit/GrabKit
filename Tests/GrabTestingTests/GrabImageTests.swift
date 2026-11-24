//
//  GrabImageTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import CoreGraphics
import Foundation
import ImageIO
import Testing

@testable import GrabTesting

@Suite("Screenshot crop, detection and PNG coding")
internal struct GrabImageTests {
  private static func image(width: Int, height: Int, gray: CGFloat) -> CGImage? {
    let context = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
    context?.setFillColor(red: gray, green: gray, blue: gray, alpha: 1)
    context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
    return context?.makeImage()
  }

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

  @Test("A near-white image is light and a near-black one dark")
  internal func detectsImages() throws {
    let light = try #require(Self.image(width: 64, height: 40, gray: 0.92))
    let dark = try #require(Self.image(width: 64, height: 40, gray: 0.15))
    #expect(GrabAppearanceDetector.appearance(of: light) == .light)
    #expect(GrabAppearanceDetector.appearance(of: dark) == .dark)
  }

  @Test("PNG round trip keeps the size and tags the scale's DPI")
  internal func pngRoundTrip() throws {
    let cgImage = try #require(Self.image(width: 40, height: 20, gray: 0.5))
    let data = try GrabImage(cgImage: cgImage, scale: 2).pngData()
    let decoded = try GrabImage(pngData: data, pointWidth: 20)
    #expect(decoded.pixelSize == CGSize(width: 40, height: 20))
    #expect(decoded.scale == 2)
    let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
    let properties = try #require(
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    )
    #expect(properties[kCGImagePropertyDPIWidth] as? Double == 144)
  }

  @Test("Cropping cuts the frames' pixels")
  internal func crop() throws {
    let cgImage = try #require(Self.image(width: 200, height: 100, gray: 0.5))
    let cropped = try GrabImage(cgImage: cgImage, scale: 2)
      .cropped(toUnionOf: [CGRect(x: 10, y: 10, width: 30, height: 20)])
    #expect(cropped.pixelSize == CGSize(width: 60, height: 40))
    #expect(throws: GrabError.unreadableImage) {
      try GrabImage(cgImage: cgImage, scale: 2).cropped(toUnionOf: [])
    }
  }

  @Test("Data that isn't an image is unreadable")
  internal func unreadable() {
    #expect(throws: GrabError.unreadableImage) {
      try GrabImage(pngData: Data([1, 2, 3]), pointWidth: 10)
    }
  }
}
