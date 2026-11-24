//
//  GrabWindowSizer.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

public import SwiftUI

/// Gives its window a fixed content size, pinned to the top left of the
/// screen's visible frame, for screenshots.
///
/// Put it in a window's background. It turns off the window's frame
/// autosave and its split views' width autosave, and sizes the window when
/// it joins it and again at 100 ms, 500 ms and 1 s, since SwiftUI applies a
/// scene's default frame after its views join the window.
public struct GrabWindowSizer: NSViewRepresentable {
  /// The content size, in points.
  public let contentSize: CGSize

  /// Creates the sizer.
  ///
  /// - Parameter contentSize: The content size, in points.
  public init(contentSize: CGSize) {
    self.contentSize = contentSize
  }

  /// Creates the view that sizes its window.
  public func makeNSView(context _: Context) -> SizingView {
    SizingView(contentSize: contentSize)
  }

  /// Does nothing: the size is fixed.
  public func updateNSView(_: SizingView, context _: Context) {}
}
