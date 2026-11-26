//
//  GrabExportOptionsTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import GrabExportCore
import Testing

@Suite("Export options")
internal struct GrabExportOptionsTests {
  @Test("Two paths empty the output folder first")
  internal func paths() {
    #expect(
      GrabExportOptions(arguments: ["run.xcresult", "shots"])
        == GrabExportOptions(bundlePath: "run.xcresult", outputPath: "shots")
    )
  }

  @Test(
    "--keep-others, before or after the paths, keeps the folder's other files",
    arguments: [
      ["--keep-others", "run.xcresult", "shots"],
      ["run.xcresult", "shots", "--keep-others"],
    ]
  )
  internal func keepOthers(arguments: [String]) {
    #expect(
      GrabExportOptions(arguments: arguments)
        == GrabExportOptions(
          bundlePath: "run.xcresult",
          outputPath: "shots",
          keepsOthers: true
        )
    )
  }

  @Test(
    "Anything else is a usage error",
    arguments: [
      [],
      ["run.xcresult"],
      ["run.xcresult", "shots", "extra"],
      ["--keep", "run.xcresult", "shots"],
      ["--keep-others"],
    ]
  )
  internal func usageError(arguments: [String]) {
    #expect(GrabExportOptions(arguments: arguments) == nil)
  }
}
