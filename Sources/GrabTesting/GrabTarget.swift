//
//  GrabTarget.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if canImport(XCUIAutomation)
  public import XCTest

  /// What a driven screen captures: a window, plus anything outside it that
  /// must show too.
  @MainActor
  public struct GrabTarget {
    /// The window, captured with `XCUIElement.screenshot()` (a flat cut-out,
    /// no shadow, at the display's scale).
    public let window: XCUIElement
    /// Elements outside the window to include, such as a menu bar title
    /// over an open menu, or a sheet `window.screenshot()` would miss.
    ///
    /// When there are any, the shot is cut from a screen capture around the
    /// union of their frames and the window's, instead.
    public let extras: [XCUIElement]

    /// A target.
    ///
    /// - Parameters:
    ///   - window: The window to capture.
    ///   - extras: Elements outside it to include.
    public init(window: XCUIElement, extras: [XCUIElement] = []) {
      self.window = window
      self.extras = extras
    }
  }
#endif
