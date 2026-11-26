//
//  Platform.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// What the platform running GrabTesting's tests offers, for
/// `.enabled(if:)` traits.
internal enum Platform {
  /// CoreGraphics and ImageIO, behind `GrabImage` and
  /// `GrabAppearanceDetector.appearance(of:)`: every Apple platform, not
  /// Linux.
  #if canImport(CoreGraphics) && canImport(ImageIO)
    internal static let isImageIOAvailable = true
  #else
    internal static let isImageIOAvailable = false
  #endif
}
