//
//  GrabError.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import Foundation

/// Why a screenshot couldn't be taken.
public enum GrabError: LocalizedError, Sendable, Equatable {
  /// An element didn't appear, or didn't reach the awaited state, in time;
  /// the associated value describes it.
  case elementNotFound(String)
  /// The capture had no readable bitmap, or the crop missed it.
  case unreadableImage
  /// The PNG couldn't be encoded.
  case encodingFailed
  /// A "quit unexpectedly" dialog (Problem Reporter) is open and would show
  /// in the shots. Dismiss it and run again.
  case crashDialogOpen
  /// A fixture file isn't in the bundle; the associated value is its name.
  case missingFixture(String)

  /// What went wrong, naming the element or file, for the test log.
  public var errorDescription: String? {
    switch self {
    case .elementNotFound(let description):
      "Timed out waiting for \(description)."
    case .unreadableImage:
      "The capture had no readable image, or the crop missed it."
    case .encodingFailed:
      "The PNG couldn't be encoded."
    case .crashDialogOpen:
      "A “quit unexpectedly” dialog is open; dismiss it and run again."
    case .missingFixture(let name):
      "The fixture \(name) isn't in the bundle."
    }
  }
}
