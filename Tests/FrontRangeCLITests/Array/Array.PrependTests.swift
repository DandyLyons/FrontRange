//
//  Array.PrependTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2026-01-08.
//

import Command
import Foundation
import FrontRange
import PathKit
import Testing

@Suite(.serialized) struct ArrayPrependTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../../.build/debug/fr"

  @Test func `Prepend adds value to beginning of array`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift", "programming"])

    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "prepend", "--key", "tags", "--value", "featured", tempFile]
    ).concatenatedString()

    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["featured", "swift", "programming"])
  }

  @Test func `Prepend skip duplicates prevents adding existing value`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift"])

    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "prepend", "--key", "tags", "--value", "swift", "--skip-duplicates", tempFile]
    ).concatenatedString()

    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift"])
  }
}
