//
//  GrabExportCommand.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import Foundation
import GrabExportCore

/// `grab-export [--keep-others] <result bundle> <output folder>`: exports a
/// screenshot run's PNG attachments into a folder, named by the names the
/// runner gave them (`01-editor-light.png`).
///
/// The output folder is emptied first, unless `--keep-others` is given:
/// then only the files this run exports are replaced, so a one-appearance
/// run keeps the other appearance's shots. Exits non-zero when the bundle
/// is missing or xcresulttool fails.
@main
internal enum GrabExportCommand {
  internal static func main() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard let options = GrabExportOptions(arguments: arguments) else {
      fail(GrabExportOptions.usage)
    }
    let bundle = URL(filePath: options.bundlePath)
    let output = URL(filePath: options.outputPath)
    do {
      let count = try export(
        bundle: bundle,
        to: output,
        keepingOthers: options.keepsOthers
      )
      print("Exported \(count) screenshots to \(output.path(percentEncoded: false))")
    } catch {
      fail("grab-export: \(error)")
    }
  }

  private static func export(
    bundle: URL,
    to output: URL,
    keepingOthers keepsOthers: Bool
  ) throws -> Int {
    let files = FileManager.default
    guard files.fileExists(atPath: bundle.path(percentEncoded: false)) else {
      fail("No result bundle at \(bundle.path(percentEncoded: false)).")
    }
    let staging = files.temporaryDirectory.appending(path: "grab-export-\(UUID())")
    try files.createDirectory(at: staging, withIntermediateDirectories: true)
    defer { try? files.removeItem(at: staging) }
    try runXcresulttool(bundle: bundle, to: staging)
    let plan = try GrabExportPlan(
      manifest: Data(contentsOf: staging.appending(path: "manifest.json"))
    )
    if !keepsOthers, files.fileExists(atPath: output.path(percentEncoded: false)) {
      try files.removeItem(at: output)
    }
    try files.createDirectory(at: output, withIntermediateDirectories: true)
    for copy in plan.copies {
      let destination = output.appending(path: copy.destination)
      if files.fileExists(atPath: destination.path(percentEncoded: false)) {
        try files.removeItem(at: destination)
      }
      try files.copyItem(
        at: staging.appending(path: copy.source),
        to: destination
      )
      print(copy.destination)
    }
    if plan.skipped > 0 {
      print("Skipped \(plan.skipped) other attachments.")
    }
    return plan.copies.count
  }

  private static func runXcresulttool(bundle: URL, to folder: URL) throws {
    let process = Process()
    process.executableURL = URL(filePath: "/usr/bin/xcrun")
    process.arguments = [
      "xcresulttool", "export", "attachments",
      "--path", bundle.path(percentEncoded: false),
      "--output-path", folder.path(percentEncoded: false),
    ]
    // Its per-attachment listing is noise here; errors still reach stderr.
    process.standardOutput = FileHandle.nullDevice
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
      fail("xcresulttool exited with \(process.terminationStatus).")
    }
  }

  private static func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(EXIT_FAILURE)
  }
}
