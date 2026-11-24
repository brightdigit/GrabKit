//
//  GrabError.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// Why a screenshot couldn't be taken.
public enum GrabError: Error, Sendable, Equatable {
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
}
