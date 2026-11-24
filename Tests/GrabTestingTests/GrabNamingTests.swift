//
//  GrabNamingTests.swift
//  GrabKit
//
//  Copyright (c) 2026 BrightDigit.
//  Licensed under the MIT License. See LICENSE.
//

import Foundation
import GrabSupport
import Testing

@testable import GrabTesting

@Suite("Names and fixtures")
internal struct GrabNamingTests {
  @Test("Base names are a two-digit number and a slug")
  internal func baseNames() {
    #expect(GrabNaming.baseName(number: 1, slug: "editor") == "01-editor")
    #expect(GrabNaming.baseName(number: 12, slug: "about") == "12-about")
  }

  @Test("Captures are named by detected appearance")
  internal func namedByDetectedAppearance() {
    #expect(
      GrabNaming.names(baseName: "02-main", detected: [.light, .dark])
        == ["02-main-light", "02-main-dark"]
    )
    #expect(
      GrabNaming.names(baseName: "02-main", detected: [.dark, .light])
        == ["02-main-dark", "02-main-light"]
    )
  }

  @Test("A capture repeating an earlier appearance isn't saved")
  internal func repeatsAreDropped() {
    #expect(
      GrabNaming.names(baseName: "01-editor", detected: [.light, .light])
        == ["01-editor-light", nil]
    )
  }

  @Test("A fixture's text drops the file's trailing newlines")
  internal func fixtureText() throws {
    let fixture = GrabFixture(name: "swift-code", subdirectory: "Fixtures")
    #expect(try fixture.text(in: .module) == #"let greeting = "Hello""#)
  }

  @Test("A missing fixture throws its name")
  internal func missingFixture() {
    #expect(throws: GrabError.missingFixture("nope")) {
      try GrabFixture(name: "nope", subdirectory: "Fixtures").text(in: .module)
    }
  }

  @Test("Errors name what they waited for")
  internal func errorDescriptions() {
    #expect(
      GrabError.elementNotFound("About panel").localizedDescription
        == "Timed out waiting for About panel."
    )
    #expect(GrabError.missingFixture("sample").localizedDescription.contains("sample"))
  }
}
