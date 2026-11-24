//
//  GrabManifestAttachment.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// One exported attachment in `manifest.json`.
public struct GrabManifestAttachment: Decodable, Sendable, Equatable {
  /// The file's name in the export folder: `<UUID>.png`.
  public let exportedFileName: String
  /// The test's name for it plus a suffix xcresulttool adds:
  /// `01-editor-light_0_<UUID>.png`.
  public let suggestedHumanReadableName: String

  /// An attachment.
  ///
  /// - Parameters:
  ///   - exportedFileName: The file's name in the export folder.
  ///   - suggestedHumanReadableName: The name xcresulttool suggests.
  public init(exportedFileName: String, suggestedHumanReadableName: String) {
    self.exportedFileName = exportedFileName
    self.suggestedHumanReadableName = suggestedHumanReadableName
  }
}
