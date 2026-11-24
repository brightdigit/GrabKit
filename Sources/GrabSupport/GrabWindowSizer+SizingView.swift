//
//  GrabWindowSizer+SizingView.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import AppKit

extension GrabWindowSizer {
  /// The view that sizes the window it joins.
  public final class SizingView: NSView {
    private static let retryDelays: [Duration] = [
      .milliseconds(100), .milliseconds(500), .seconds(1),
    ]

    private let contentSize: CGSize

    internal init(contentSize: CGSize) {
      self.contentSize = contentSize
      super.init(frame: .zero)
    }

    @available(*, unavailable)
    internal required init?(coder _: NSCoder) {
      fatalError("init(coder:) is unavailable")
    }

    private static func stopAutosaving(in view: NSView) {
      if let splitView = view as? NSSplitView, splitView.autosaveName != nil {
        splitView.autosaveName = nil
      }
      for subview in view.subviews {
        stopAutosaving(in: subview)
      }
    }

    /// Sizes the window it joins, then again after SwiftUI's late frame.
    override public func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      guard window != nil else {
        return
      }
      resize()
      Task { @MainActor [weak self] in
        for delay in Self.retryDelays {
          try? await Task.sleep(for: delay)
          self?.resize()
        }
      }
    }

    private func resize() {
      guard let window else {
        return
      }
      window.setFrameAutosaveName("")
      if let contentView = window.contentView {
        Self.stopAutosaving(in: contentView)
      }
      // One frame change for size and position. SwiftUI windows draw their
      // content under the title bar, so the frame is the content size.
      var frame = window.frameRect(
        forContentRect: NSRect(origin: .zero, size: contentSize)
      )
      if let visible = (window.screen ?? NSScreen.main)?.visibleFrame {
        frame.origin = NSPoint(x: visible.minX, y: visible.maxY - frame.height)
      }
      window.setFrame(frame, display: true)
    }
  }
}
