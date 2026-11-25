//
//  GrabAppearanceDetector.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import GrabSupport

#if canImport(CoreGraphics)
  public import CoreGraphics
#endif

/// Tells light from dark by a captured image's average brightness.
public enum GrabAppearanceDetector {
  /// The average luminance (0 to 1) from which an image counts as light.
  public static let lightThreshold = 0.5

  /// The side of the square the image is shrunk to before measuring.
  public static let sampleSide = 32

  /// The appearance for an average luminance from 0 (black) to 1 (white).
  ///
  /// - Parameter averageLuminance: The luminance.
  /// - Returns: `.light` from ``lightThreshold`` up.
  public static func appearance(averageLuminance: Double) -> GrabAppearance {
    averageLuminance >= lightThreshold ? .light : .dark
  }

  #if canImport(CoreGraphics)
    /// The appearance of `image`, from its average luminance.
    ///
    /// - Parameter image: The capture.
    /// - Returns: Its appearance.
    public static func appearance(of image: CGImage) -> GrabAppearance {
      appearance(averageLuminance: averageLuminance(of: image))
    }

    /// The image's average Rec. 709 luminance, from 0 to 1, measured on a
    /// 32×32 downsample; 0 if the image can't be drawn.
    ///
    /// - Parameter image: The capture.
    /// - Returns: The luminance.
    public static func averageLuminance(of image: CGImage) -> Double {
      let side = sampleSide
      var pixels = [UInt8](repeating: 0, count: side * side * 4)
      let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
        guard
          let context = CGContext(
            data: buffer.baseAddress,
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: side * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
          )
        else {
          return false
        }
        context.interpolationQuality = .medium
        context.draw(image, in: CGRect(x: 0, y: 0, width: side, height: side))
        return true
      }
      guard drawn else {
        return 0
      }
      return luminance(ofRGBX: pixels)
    }
  #endif

  /// The average Rec. 709 luminance (0 to 1) of 8-bit RGBX pixels.
  internal static func luminance(ofRGBX pixels: [UInt8]) -> Double {
    let count = pixels.count / 4
    guard count > 0 else {
      return 0
    }
    var total = 0.0
    for index in stride(from: 0, to: count * 4, by: 4) {
      total +=
        0.2126 * Double(pixels[index]) + 0.7152 * Double(pixels[index + 1])
        + 0.0722 * Double(pixels[index + 2])
    }
    return total / Double(count) / 255
  }
}
