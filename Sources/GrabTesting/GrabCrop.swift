//
//  GrabCrop.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import CoreGraphics

/// Works out the pixel rectangle to cut from a screen capture.
public enum GrabCrop {
  /// The points-to-pixels scale of a capture: its width in pixels over the
  /// captured element's width in points, or `nil` if either is zero.
  ///
  /// A screen capture reports its size in pixels, so the scale comes from
  /// an element whose frame (points) and capture (pixels) are both known,
  /// such as the window.
  ///
  /// - Parameters:
  ///   - pixelWidth: The capture's width in pixels.
  ///   - pointWidth: The captured element's width in points.
  /// - Returns: Pixels per point.
  public static func scale(pixelWidth: Int, pointWidth: CGFloat) -> CGFloat? {
    guard pixelWidth > 0, pointWidth > 0 else {
      return nil
    }
    return CGFloat(pixelWidth) / pointWidth
  }

  /// The union of `frames` (screen points, top-left origin, as
  /// `XCUIElement.frame` reports them) in pixels at `scale`, rounded out to
  /// whole pixels and clipped to an image of `pixelSize`.
  ///
  /// - Parameters:
  ///   - frames: The frames to cover, in points.
  ///   - scale: Pixels per point.
  ///   - pixelSize: The image's size in pixels.
  /// - Returns: The rectangle, or `nil` if no frame is given or the union
  ///   misses the image.
  public static func pixelRect(
    unionOf frames: [CGRect],
    scale: CGFloat,
    pixelSize: CGSize
  ) -> CGRect? {
    guard let first = frames.first else {
      return nil
    }
    let union = frames.dropFirst().reduce(first) { $0.union($1) }
    let scaled = CGRect(
      x: union.minX * scale,
      y: union.minY * scale,
      width: union.width * scale,
      height: union.height * scale
    )
    .integral
    let clipped = scaled.intersection(CGRect(origin: .zero, size: pixelSize))
    return clipped.isNull || clipped.isEmpty ? nil : clipped
  }
}
