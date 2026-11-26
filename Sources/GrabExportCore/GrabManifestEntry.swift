//
//  GrabManifestEntry.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// One test's entry in the `manifest.json` that
/// `xcresulttool export attachments` writes.
public struct GrabManifestEntry: Decodable, Sendable, Equatable {
  /// The test, such as `ScreenshotTests/test01Editor()`.
  public let testIdentifier: String?
  /// The test's exported attachments.
  public let attachments: [GrabManifestAttachment]

  /// An entry.
  ///
  /// - Parameters:
  ///   - testIdentifier: The test.
  ///   - attachments: Its attachments.
  public init(testIdentifier: String?, attachments: [GrabManifestAttachment]) {
    self.testIdentifier = testIdentifier
    self.attachments = attachments
  }
}
