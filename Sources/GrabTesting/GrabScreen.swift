//
//  GrabScreen.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if canImport(XCUIAutomation)
  public import GrabSupport
  public import XCTest

  /// One screenshot: how to launch the app for it and how to drive the app
  /// to it.
  ///
  /// An app's screen list is an enum, one case per design, conforming to
  /// this protocol.
  @MainActor
  public protocol GrabScreen {
    /// The file name without appearance or extension: `01-editor`.
    var baseName: String { get }

    /// The launch arguments for one capture in `appearance`, usually
    /// ``GrabLaunchArguments/launchArguments(appearance:extra:)``.
    ///
    /// - Parameter appearance: The appearance to launch in.
    /// - Returns: The arguments.
    func launchArguments(appearance: GrabAppearance) -> [String]

    /// The launch environment: fixtures and any other demo inputs.
    ///
    /// - Returns: The environment.
    func launchEnvironment() throws -> [String: String]

    /// Sets the screen's state in the launched app.
    ///
    /// - Parameter app: The app, launched and activated.
    /// - Returns: What to capture.
    func drive(_ app: XCUIApplication) throws -> GrabTarget
  }

  extension GrabScreen {
    /// No launch environment.
    public func launchEnvironment() throws -> [String: String] {
      [:]
    }
  }
#endif
