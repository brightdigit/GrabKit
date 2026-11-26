//
//  GrabNaming.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import GrabSupport

/// File names for one screen's captures.
///
/// Each capture is named for the appearance it was *detected* to have, not
/// the one asked for, so a run whose appearance switch failed can't save a
/// light image as `-dark`. Only the first capture of each detected
/// appearance is kept.
public enum GrabNaming {
  /// The name for each capture, in capture order, or `nil` for a capture
  /// that repeats an earlier capture's appearance and isn't saved.
  ///
  /// - Parameters:
  ///   - baseName: The screen's `NN-slug`.
  ///   - detected: Each capture's detected appearance, in capture order.
  /// - Returns: `NN-slug-light`, `NN-slug-dark` or `nil` per capture.
  public static func names(
    baseName: String,
    detected: [GrabAppearance]
  ) -> [String?] {
    var seen: Set<GrabAppearance> = []
    return detected.map { appearance in
      guard seen.insert(appearance).inserted else {
        return nil
      }
      return "\(baseName)-\(appearance.rawValue)"
    }
  }

  /// A screen's `NN-slug` from its number, from 1, and its slug.
  ///
  /// - Parameters:
  ///   - number: The screen's number in the design's order.
  ///   - slug: The screen's kebab-case name.
  /// - Returns: `01-editor`.
  public static func baseName(number: Int, slug: String) -> String {
    let digits = number < 10 ? "0\(number)" : "\(number)"
    return "\(digits)-\(slug)"
  }
}
