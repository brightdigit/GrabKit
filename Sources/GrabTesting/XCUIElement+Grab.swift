//
//  XCUIElement+Grab.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if canImport(XCUIAutomation)
  public import CoreGraphics
  public import Foundation
  public import XCTest

  extension XCUIElement {
    /// How long to wait for an element before failing, in seconds.
    public static let grabTimeout: TimeInterval = 15

    /// How often a poll checks again.
    private static let pollInterval: TimeInterval = 0.05

    /// The first descendant with the identifier: `app.element(.editor.text)`.
    ///
    /// - Parameter id: An app's accessibility identifier.
    /// - Returns: The query's first match.
    @MainActor
    public func element<ID: RawRepresentable>(_ id: ID) -> XCUIElement
    where ID.RawValue == String {
      descendants(matching: .any).matching(identifier: id.rawValue).firstMatch
    }

    /// The first window containing an element with the identifier.
    ///
    /// - Parameter id: An app's accessibility identifier.
    /// - Returns: The query's first match.
    @MainActor
    public func window<ID: RawRepresentable>(containing id: ID) -> XCUIElement
    where ID.RawValue == String {
      windows.containing(.any, identifier: id.rawValue).firstMatch
    }

    /// Descendants whose identifier starts with `prefix`, such as every row
    /// of a grid (`grid.row.`).
    ///
    /// - Parameter prefix: The identifiers' prefix.
    /// - Returns: The query.
    @MainActor
    public func elements(identifierPrefix prefix: String) -> XCUIElementQuery {
      descendants(matching: .any)
        .matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
    }

    /// Waits for the element to exist.
    ///
    /// - Parameters:
    ///   - description: What the element is, for the error.
    ///   - timeout: How long to wait, in seconds.
    /// - Returns: The element.
    /// - Throws: ``GrabError/elementNotFound(_:)``.
    @MainActor
    @discardableResult
    public func waitToExist(
      _ description: String,
      timeout: TimeInterval = grabTimeout
    ) throws(GrabError) -> XCUIElement {
      guard waitForExistence(timeout: timeout) else {
        throw .elementNotFound(description)
      }
      return self
    }

    /// Waits for the element to exist and match `condition`, such as being
    /// enabled or hittable, or showing a fixture's text.
    ///
    /// - Parameters:
    ///   - description: What is awaited, for the error.
    ///   - timeout: How long to wait, in seconds.
    ///   - condition: The state to wait for.
    /// - Returns: The element.
    /// - Throws: ``GrabError/elementNotFound(_:)``.
    @MainActor
    @discardableResult
    public func waitUntil(
      _ description: String,
      timeout: TimeInterval = grabTimeout,
      _ condition: (XCUIElement) -> Bool
    ) throws(GrabError) -> XCUIElement {
      try waitToExist(description, timeout: timeout)
      guard poll(timeout: timeout, until: condition) else {
        throw .elementNotFound(description)
      }
      return self
    }

    /// Waits until the element's frame is the same on two checks in a row
    /// (a window being sized, a sheet sliding in), up to `timeout`.
    ///
    /// - Parameter timeout: How long to wait, in seconds.
    /// - Returns: Whether the frame settled in time.
    @MainActor
    @discardableResult
    public func waitForStableFrame(timeout: TimeInterval = 5) -> Bool {
      var last = frame
      return poll(timeout: timeout) { element in
        let current = element.frame
        defer { last = current }
        return current == last && !current.isEmpty
      }
    }

    /// Waits until the element's frame has `size` (points), up to `timeout`.
    ///
    /// - Parameters:
    ///   - size: The size to wait for.
    ///   - timeout: How long to wait, in seconds.
    /// - Returns: Whether it did.
    @MainActor
    @discardableResult
    public func waitForSize(_ size: CGSize, timeout: TimeInterval = 5) -> Bool {
      poll(timeout: timeout) { $0.frame.size == size }
    }

    /// Checks `condition` every 50 ms, running the run loop in between,
    /// until it holds or `timeout` passes.
    ///
    /// - Parameters:
    ///   - timeout: How long to wait, in seconds.
    ///   - condition: The state to wait for.
    /// - Returns: Whether the condition held.
    @MainActor
    public func poll(
      timeout: TimeInterval,
      until condition: (XCUIElement) -> Bool
    ) -> Bool {
      let deadline = Date(timeIntervalSinceNow: timeout)
      while !condition(self) {
        guard Date() < deadline else {
          return false
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: Self.pollInterval))
      }
      return true
    }

    /// Moves the pointer just right of this element (a window), so no hover
    /// effect or tooltip shows in the capture.
    ///
    /// Does nothing on tvOS, visionOS and watchOS, which have no pointer to
    /// hover with.
    @MainActor
    public func parkPointer() {
      #if os(macOS) || os(iOS)
        coordinate(withNormalizedOffset: CGVector(dx: 1.02, dy: 0.5)).hover()
      #endif
    }
  }
#endif
