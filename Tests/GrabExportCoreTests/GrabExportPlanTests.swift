//
//  GrabExportPlanTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import Foundation
import GrabExportCore
import Testing

@Suite("Export plan")
internal struct GrabExportPlanTests {
  private static let uuid = "AE0A1CAB-CEA0-45F0-9726-A2E0C41F2C1C"

  private static func attachment(_ exported: String, _ suggested: String)
    -> GrabManifestAttachment
  {
    GrabManifestAttachment(
      exportedFileName: exported,
      suggestedHumanReadableName: suggested
    )
  }

  @Test(
    "Screenshot names lose xcresulttool's suffix; anything else is skipped",
    arguments: [
      ("01-connections-dark_0_\(uuid).png", "01-connections-dark"),
      ("03-main-production-light_1_\(uuid).png", "03-main-production-light"),
      ("01-editor-light.png", "01-editor-light"),
      ("01-editor_0_\(uuid).png", nil),
      ("Screenshot at failure_0_\(uuid).png", nil),
      ("kXCTAttachmentLegacyScreenImageData_1_\(uuid).jpeg", nil),
    ] as [(String, String?)]
  )
  internal func screenshotName(suggested: String, expected: String?) {
    #expect(GrabExportPlan.screenshotName(from: suggested) == expected)
  }

  @Test("Only screenshot PNGs are copied, once per name, in manifest order")
  internal func plan() {
    let plan = GrabExportPlan(entries: [
      GrabManifestEntry(
        testIdentifier: "ScreenshotTests/test01Editor()",
        attachments: [
          Self.attachment("A.png", "01-editor-dark_0_\(Self.uuid).png"),
          Self.attachment("B.png", "01-editor-light_0_\(Self.uuid).png"),
          Self.attachment("C.png", "01-editor-light_1_\(Self.uuid).png"),
        ]
      ),
      GrabManifestEntry(
        testIdentifier: "ScreenshotTests/test02Empty()",
        attachments: [
          Self.attachment("D.mp4", "Screen Recording_0_\(Self.uuid).mp4"),
          Self.attachment("E.png", "Screenshot at failure_0_\(Self.uuid).png"),
        ]
      ),
    ])
    #expect(plan.copies.map(\.source) == ["A.png", "B.png"])
    #expect(
      plan.copies.map(\.destination) == ["01-editor-dark.png", "01-editor-light.png"]
    )
    #expect(plan.skipped == 3)
  }

  @Test("A manifest decodes, ignoring the fields GrabKit doesn't use")
  internal func decodes() throws {
    let json = """
      [{"testIdentifier": "ScreenshotTests/test01Editor()",
        "testIdentifierURL": "test://x",
        "attachments": [{"exportedFileName": "A.png",
          "suggestedHumanReadableName": "01-editor-dark_0_\(Self.uuid).png",
          "isAssociatedWithFailure": false, "timestamp": 1.5}]}]
      """
    let plan = try GrabExportPlan(manifest: Data(json.utf8))
    #expect(plan.copies.map(\.destination) == ["01-editor-dark.png"])
  }
}
