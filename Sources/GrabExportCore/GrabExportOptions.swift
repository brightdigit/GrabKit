//
//  GrabExportOptions.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

/// The options of the `grab-export` command.
///
/// `grab-export [--keep-others] <result bundle> <output folder>`.
public struct GrabExportOptions: Sendable, Equatable {
  /// The flag that keeps the output folder's other files.
  public static let keepOthersFlag = "--keep-others"

  /// The usage line.
  public static let usage =
    "Usage: grab-export [\(keepOthersFlag)] <result bundle> <output folder>"

  /// The result bundle's path.
  public let bundlePath: String
  /// The output folder's path.
  public let outputPath: String
  /// Whether to replace only the files this run exports and leave the
  /// folder's other files, such as the other appearance from an earlier
  /// run, instead of emptying the folder first.
  public let keepsOthers: Bool

  /// Options.
  ///
  /// - Parameters:
  ///   - bundlePath: The result bundle's path.
  ///   - outputPath: The output folder's path.
  ///   - keepsOthers: Whether to leave the folder's other files.
  public init(bundlePath: String, outputPath: String, keepsOthers: Bool = false) {
    self.bundlePath = bundlePath
    self.outputPath = outputPath
    self.keepsOthers = keepsOthers
  }

  /// Reads the arguments after the command's name, or `nil` if they don't
  /// match ``usage``.
  ///
  /// - Parameter arguments: The arguments, without the command's name.
  public init?(arguments: [String]) {
    let keepsOthers = arguments.contains(Self.keepOthersFlag)
    let paths = arguments.filter { $0 != Self.keepOthersFlag }
    guard paths.count == 2, !paths.contains(where: { $0.hasPrefix("--") }) else {
      return nil
    }
    self.init(bundlePath: paths[0], outputPath: paths[1], keepsOthers: keepsOthers)
  }
}
