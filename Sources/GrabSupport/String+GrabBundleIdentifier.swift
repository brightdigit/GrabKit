//
//  String+GrabBundleIdentifier.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

extension String {
  /// The suffix of a Screenshots build's bundle ID:
  /// `com.example.App.Screenshots`.
  ///
  /// The separate ID gives screenshot runs their own sandbox container,
  /// defaults and privacy permissions, and keeps XCUITest from terminating
  /// the copy of the app the user is running.
  public static let grabBundleIdentifierSuffix = ".Screenshots"

  /// Whether this is a Screenshots build's bundle ID.
  public var isGrabBundleIdentifier: Bool {
    hasSuffix(Self.grabBundleIdentifierSuffix)
  }
}
