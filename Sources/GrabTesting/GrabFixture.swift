//
//  GrabFixture.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import Foundation

/// A text fixture a screenshot shows, kept as a file in the UI tests'
/// resources and passed to the app in its launch environment, so the app
/// itself ships no sample content.
public struct GrabFixture: Sendable, Hashable {
  /// The file's name, without its extension.
  public let name: String
  /// The file's extension.
  public let fileExtension: String
  /// The folder inside the bundle's resources, if any.
  public let subdirectory: String?

  /// Names a fixture.
  ///
  /// - Parameters:
  ///   - name: The file's name, without its extension.
  ///   - fileExtension: The file's extension.
  ///   - subdirectory: The folder inside the bundle's resources.
  public init(name: String, fileExtension: String = "txt", subdirectory: String? = nil) {
    self.name = name
    self.fileExtension = fileExtension
    self.subdirectory = subdirectory
  }

  /// Reads the fixture's text, without the file's trailing newlines.
  ///
  /// - Parameter bundle: The bundle holding it, usually the caller's
  ///   `Bundle.module`.
  /// - Returns: The text.
  /// - Throws: ``GrabError/missingFixture(_:)`` when the file isn't there.
  public func text(in bundle: Bundle) throws(GrabError) -> String {
    guard
      let url = bundle.url(
        forResource: name,
        withExtension: fileExtension,
        subdirectory: subdirectory
      ),
      let text = try? String(contentsOf: url, encoding: .utf8)
    else {
      throw .missingFixture(name)
    }
    var trimmed = Substring(text)
    while trimmed.last?.isNewline == true {
      trimmed.removeLast()
    }
    return String(trimmed)
  }
}
