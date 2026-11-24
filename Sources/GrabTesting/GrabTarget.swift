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
    /// Whether the window should have the runner's `windowSize`: `false`
    /// for a window the app doesn't size, such as an About panel or an
    /// alert.
    public let checksWindowSize: Bool
    /// Whether to move the pointer off the window before capturing, so no
    /// hover or tooltip shows: `false` for an open menu, which closes its
    /// submenu when the pointer leaves it.
    public let parksPointer: Bool

    /// A target.
    ///
    /// - Parameters:
    ///   - window: The window to capture.
    ///   - extras: Elements outside it to include.
    ///   - checksWindowSize: Whether the window should have the runner's
    ///     `windowSize`.
    ///   - parksPointer: Whether to move the pointer off the window first.
    public init(
      window: XCUIElement,
      extras: [XCUIElement] = [],
      checksWindowSize: Bool = true,
      parksPointer: Bool = true
    ) {
      self.window = window
      self.extras = extras
      self.checksWindowSize = checksWindowSize
      self.parksPointer = parksPointer
    }
  }
#endif
