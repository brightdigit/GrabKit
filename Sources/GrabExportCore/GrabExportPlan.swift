//
//  GrabExportPlan.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import Foundation

/// Which exported files to copy, and under which names.
///
/// Only PNGs the runner named (`NN-slug-light`, `NN-slug-dark`) are kept,
/// so the failure screenshots and screen recordings XCTest attaches to a
/// failed test never land among the website shots.
public struct GrabExportPlan: Sendable, Equatable {
  /// One file to copy.
  public struct Copy: Sendable, Equatable {
    /// The file's name in the export folder.
    public let source: String
    /// Its name in the output folder: `01-editor-light.png`.
    public let destination: String
  }

  /// The files to copy, in manifest order, one per destination name.
  public let copies: [Copy]
  /// How many attachments were skipped.
  public let skipped: Int

  /// Plans the copies for a manifest's entries.
  ///
  /// - Parameter entries: The decoded `manifest.json`.
  public init(entries: [GrabManifestEntry]) {
    var copies: [Copy] = []
    var seen: Set<String> = []
    var skipped = 0
    for attachment in entries.flatMap(\.attachments) {
      guard attachment.exportedFileName.hasSuffix(".png"),
        let name = Self.screenshotName(from: attachment.suggestedHumanReadableName),
        seen.insert(name).inserted
      else {
        skipped += 1
        continue
      }
      copies.append(Copy(source: attachment.exportedFileName, destination: "\(name).png"))
    }
    self.copies = copies
    self.skipped = skipped
  }

  /// Plans the copies for a `manifest.json`.
  ///
  /// - Parameter manifest: The file's data.
  /// - Throws: A decoding error if it isn't a manifest.
  public init(manifest: Data) throws {
    self.init(entries: try JSONDecoder().decode([GrabManifestEntry].self, from: manifest))
  }

  /// The runner's name inside xcresulttool's suggested name, or `nil` if it
  /// isn't a screenshot name.
  ///
  /// `01-editor-light_0_<UUID>.png` gives `01-editor-light`.
  ///
  /// - Parameter suggested: The suggested human-readable name.
  /// - Returns: The screenshot's name, without extension.
  public static func screenshotName(from suggested: String) -> String? {
    var name = suggested
    if name.hasSuffix(".png") {
      name.removeLast(4)
    }
    if let range = name.range(
      of: #"_[0-9]+_[0-9A-Fa-f-]{36}$"#,
      options: .regularExpression
    ) {
      name.removeSubrange(range)
    }
    let pattern = #"^[0-9]{2,}-[a-z0-9-]+-(light|dark)$"#
    return name.range(of: pattern, options: .regularExpression) == nil ? nil : name
  }
}
