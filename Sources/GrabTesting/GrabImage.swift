//
//  GrabImage.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import CoreGraphics
public import Foundation
import ImageIO

/// A captured image: its pixels plus the points-to-pixels scale.
///
/// PNG in and out goes through ImageIO, not AppKit.
public struct GrabImage: @unchecked Sendable {
  private static let pngType = "public.png"

  /// The pixels.
  public let cgImage: CGImage
  /// Pixels per point (2 on a Retina display).
  public let scale: CGFloat

  /// The size in pixels.
  public var pixelSize: CGSize {
    CGSize(width: cgImage.width, height: cgImage.height)
  }

  /// Wraps an image whose scale is known.
  public init(cgImage: CGImage, scale: CGFloat) {
    self.cgImage = cgImage
    self.scale = scale
  }

  /// Decodes PNG data, such as `XCUIScreenshot.pngRepresentation`.
  ///
  /// - Parameters:
  ///   - pngData: The encoded image.
  ///   - pointWidth: The captured width in points, which gives the scale.
  public init(pngData: Data, pointWidth: CGFloat) throws(GrabError) {
    let image = try Self.decode(pngData)
    guard
      let scale = GrabCrop.scale(pixelWidth: image.width, pointWidth: pointWidth)
    else {
      throw .unreadableImage
    }
    self.init(cgImage: image, scale: scale)
  }

  /// Decodes PNG data whose scale is known, such as a screen capture's
  /// (`XCUIScreen.main.screenshot().pngRepresentation`), whose size is in
  /// pixels.
  public init(pngData: Data, scale: CGFloat) throws(GrabError) {
    self.init(cgImage: try Self.decode(pngData), scale: scale)
  }

  private static func decode(_ pngData: Data) throws(GrabError) -> CGImage {
    guard
      let source = CGImageSourceCreateWithData(pngData as CFData, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      throw .unreadableImage
    }
    return image
  }

  /// The part of the image covering `frames` (screen points, top-left
  /// origin).
  public func cropped(toUnionOf frames: [CGRect]) throws(GrabError) -> Self {
    guard
      let rect = GrabCrop.pixelRect(
        unionOf: frames,
        scale: scale,
        pixelSize: pixelSize
      ),
      let cropped = cgImage.cropping(to: rect)
    else {
      throw .unreadableImage
    }
    return Self(cgImage: cropped, scale: scale)
  }

  /// The image as PNG data, tagged with its scale's DPI (144 at 2x).
  public func pngData() throws(GrabError) -> Data {
    let data = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        data,
        Self.pngType as CFString,
        1,
        nil
      )
    else {
      throw .encodingFailed
    }
    let dpi = 72 * scale
    let properties =
      [
        kCGImagePropertyDPIWidth: dpi,
        kCGImagePropertyDPIHeight: dpi,
      ] as CFDictionary
    CGImageDestinationAddImage(destination, cgImage, properties)
    guard CGImageDestinationFinalize(destination) else {
      throw .encodingFailed
    }
    return data as Data
  }
}
