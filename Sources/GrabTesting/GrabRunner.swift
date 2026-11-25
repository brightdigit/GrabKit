//
//  GrabRunner.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

#if canImport(XCUIAutomation)
  public import CoreGraphics
  import Foundation
  public import GrabSupport
  public import XCTest

  /// Launches the app in screenshot mode, drives it to a screen and attaches
  /// the PNGs to the test, once per appearance.
  ///
  /// `make screenshots` runs the UI tests and `grab-export` exports the
  /// attachments by their names (`01-editor-light.png`).
  @MainActor
  public struct GrabRunner {
    /// Problem Reporter shows "… quit unexpectedly".
    private static let problemReporterID = "com.apple.ProblemReporter"

    /// The window's expected size in points, or `nil` not to check it.
    public let windowSize: CGSize?
    /// The appearances to capture, in order.
    public let appearances: [GrabAppearance]

    /// A runner.
    ///
    /// - Parameters:
    ///   - launchArguments: The app's screenshot arguments; the appearances
    ///     come from their `GrabLaunchArguments.appearancesEnvironmentKey`.
    ///   - windowSize: The window's expected size in points, or `nil`.
    public init(launchArguments: GrabLaunchArguments, windowSize: CGSize? = nil) {
      let value = ProcessInfo.processInfo.environment[
        launchArguments.appearancesEnvironmentKey
      ]
      self.init(
        appearances: GrabAppearance.requested(from: value),
        windowSize: windowSize
      )
    }

    /// A runner for explicit appearances.
    ///
    /// - Parameters:
    ///   - appearances: The appearances to capture, in order.
    ///   - windowSize: The window's expected size in points, or `nil`.
    public init(appearances: [GrabAppearance], windowSize: CGSize? = nil) {
      self.appearances = appearances
      self.windowSize = windowSize
    }

    private static func image(of target: GrabTarget) throws -> GrabImage {
      let window = target.window
      let shot = try GrabImage(
        pngData: window.screenshot().pngRepresentation,
        pointWidth: window.frame.width
      )
      guard target.capturesScreen else {
        return shot
      }
      // A screen capture's image is in pixels; the window's capture gives
      // the points-to-pixels scale.
      let frames = [window.frame] + target.extras.map(\.frame)
      return try GrabImage(
        pngData: XCUIScreen.main.screenshot().pngRepresentation,
        scale: shot.scale
      )
      .cropped(toUnionOf: frames)
    }

    /// Throws if a "quit unexpectedly" dialog is open: it would show in the
    /// shots, and XCTest doesn't dismiss it.
    private static func checkForCrashDialog() throws {
      let reporter = XCUIApplication(bundleIdentifier: problemReporterID)
      guard reporter.state == .notRunning || !reporter.windows.firstMatch.exists else {
        note("A “quit unexpectedly” dialog is open; dismiss it and run again.")
        throw GrabError.crashDialogOpen
      }
    }

    /// Prints `message` to the test log and records it as an activity in
    /// the result bundle.
    private static func note(_ message: String) {
      print("[screenshots] \(message)")
      XCTContext.runActivity(named: message) { _ in }
    }

    /// Captures `screen` in each appearance and attaches the PNGs to
    /// `testCase`, named by ``GrabNaming``.
    ///
    /// Each appearance is a fresh launch. The Mac's appearance is switched
    /// too (so menus and sheets match the window) while the app is still
    /// frontmost, before it's terminated, since XCTest then waits for the
    /// frontmost app to idle. The Mac's appearance from before the run's
    /// first capture is restored after the last.
    ///
    /// - Parameters:
    ///   - screen: The screen to capture.
    ///   - testCase: The test to attach the PNGs to.
    public func capture(_ screen: some GrabScreen, in testCase: XCTestCase) throws {
      guard let first = appearances.first else {
        return
      }
      let original = Self.originalAppearance
      XCUIDevice.shared.appearance = Self.deviceAppearance(first)
      var images: [GrabImage] = []
      for (index, appearance) in appearances.enumerated() {
        let next =
          appearances.indices.contains(index + 1)
          ? Self.deviceAppearance(appearances[index + 1]) : original
        images.append(try captureOnce(screen, appearance: appearance, then: next))
      }
      try attach(images, of: screen, to: testCase)
    }

    private func attach(
      _ images: [GrabImage],
      of screen: some GrabScreen,
      to testCase: XCTestCase
    ) throws {
      let detected = images.map { GrabAppearanceDetector.appearance(of: $0.cgImage) }
      for (asked, found) in zip(appearances, detected) where asked != found {
        Self.note(
          "\(screen.baseName): asked for \(asked.rawValue), captured \(found.rawValue)"
        )
      }
      let names = GrabNaming.names(baseName: screen.baseName, detected: detected)
      for (image, name) in zip(images, names) {
        guard let name else {
          continue
        }
        let attachment = XCTAttachment(
          data: try image.pngData(),
          uniformTypeIdentifier: "public.png"
        )
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
      }
    }

    private func captureOnce(
      _ screen: some GrabScreen,
      appearance: GrabAppearance,
      then next: XCUIDevice.Appearance
    ) throws -> GrabImage {
      try Self.checkForCrashDialog()
      let app = XCUIApplication()
      app.launchArguments = screen.launchArguments(appearance: appearance)
      app.launchEnvironment = try screen.launchEnvironment()
      app.launch()
      defer { app.terminate() }
      // Runs before the terminate above, while the app is frontmost.
      defer { XCUIDevice.shared.appearance = next }
      app.activate()
      let target = try screen.drive(app)
      let window = target.window
      if let windowSize, target.checksWindowSize, !window.waitForSize(windowSize) {
        Self.note(
          "\(screen.baseName): window is \(window.frame.size), not \(windowSize)"
            + " (Stage Manager, or a display smaller than the window?)"
        )
      }
      if target.parksPointer {
        window.parkPointer()
      }
      window.waitForStableFrame()
      for extra in target.extras {
        extra.waitForStableFrame()
      }
      try Self.checkForCrashDialog()
      return try Self.image(of: target)
    }
  }
#endif
