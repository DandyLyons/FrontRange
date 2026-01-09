//
//  Array.RemoveTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2026-01-08.
//

import Command
import Foundation
import FrontRange
import PathKit
import Testing

@Suite(.serialized) struct ArrayRemoveTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../../.build/debug/fr"

  @Test func `Remove removes first occurrence from array`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift", "programming", "tutorial"])

    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "remove", "--key", "tags", "--value", "programming", tempFile]
    ).concatenatedString()

    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift", "tutorial"])
  }

  @Test func `Remove only removes first occurrence when duplicates exist`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift", "swift", "programming"])

    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "remove", "--key", "tags", "--value", "swift", tempFile]
    ).concatenatedString()

    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift", "programming"])
  }

  @Test func `Remove case insensitive removal`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["Swift", "programming"])

    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "remove", "--key", "tags", "--value", "swift", "-i", tempFile]
    ).concatenatedString()

    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["programming"])
  }
}
