//
//  GrabImageTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import Testing

@testable import GrabTesting

#if canImport(CoreGraphics) && canImport(ImageIO)
  import CoreGraphics
  import Foundation
  import ImageIO

  @Suite(
    "Screenshot detection and PNG coding",
    .enabled(if: Platform.isImageIOAvailable)
  )
  // The #else branch declares the same suite again: a skipped stub on Linux.
  // swiftlint:disable:next file_types_order
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
#else
  /// `GrabImage` needs CoreGraphics and ImageIO, which Linux lacks; the
  /// suite shows as skipped there.
  @Suite(
    "Screenshot detection and PNG coding",
    .enabled(if: Platform.isImageIOAvailable)
  )
  // swiftlint:disable:next one_declaration_per_file
  internal struct GrabImageTests {
    @Test("GrabImage needs CoreGraphics and ImageIO")
    internal func unavailable() {}
  }
#endif
