//
//  Array.AppendTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2026-01-08.
//

import Command
import CustomDump
import Foundation
import FrontRange
import PathKit
import Testing

@Suite(.serialized) struct ArrayAppendTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../../.build/debug/fr"

  @Test func `Append adds value to end of array`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift", "programming"])

    // fr array append --key tags --value tutorial tempfile
    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "append", "--key", "tags", "--value", "tutorial", tempFile]
    ).concatenatedString()

    // Verify the array was updated
    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift", "programming", "tutorial"])
  }

  @Test func `Append skip duplicates prevents adding existing value`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift"])

    // fr array append --key tags --value swift --skip-duplicates tempfile
    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "append", "--key", "tags", "--value", "swift", "--skip-duplicates", tempFile]
    ).concatenatedString()

    // Verify the array was NOT modified
    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift"])
  }

  @Test func `Append without skip duplicates allows duplicates`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["swift"])

    // fr array append --key tags --value swift tempfile (no --skip-duplicates)
    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "append", "--key", "tags", "--value", "swift", tempFile]
    ).concatenatedString()

    // Verify the array now has duplicate
    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift", "swift"])
  }

  @Test func `Append case insensitive duplicate detection`() async throws {
    let tempFile = try createTempFileWithArray(key: "tags", values: ["Swift"])

    // fr array append --key tags --value swift -i --skip-duplicates tempfile
    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "append", "--key", "tags", "--value", "swift", "-i", "--skip-duplicates", tempFile]
    ).concatenatedString()

    // Verify the array was NOT modified (case-insensitive match)
    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["Swift"])
  }
}
