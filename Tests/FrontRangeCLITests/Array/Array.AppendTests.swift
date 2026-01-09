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

  @Test func `Append creates array if key does not exist`() async throws {
    // Create a temp file with NO tags key
    let tempFileURL = try createTempFile(withContent: """
      ---
      title: "Test Post"
      ---
      Body content here.
      """)
    let tempFile = tempFileURL.path

    // fr array append --key tags --value swift tempfile
    _ = try await commandRunner.run(
      arguments: [cliPath, "array", "append", "--key", "tags", "--value", "swift", tempFile]
    ).concatenatedString()

    // Verify the array was created with the value
    let content = try Path(tempFile).read(.utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let values = try extractArrayValues(from: doc, key: "tags")

    #expect(values == ["swift"])
  }

  @Test func `Append errors if key exists but is not an array`() async throws {
    // Create a temp file where tags is a string, not an array
    let tempFileURL = try createTempFile(withContent: """
      ---
      title: "Test Post"
      tags: "not-an-array"
      ---
      Body content here.
      """)
    let tempFile = tempFileURL.path

    // fr array append --key tags --value swift tempfile
    // This should fail
    await #expect(throws: (any Error).self) {
      _ = try await commandRunner.run(
        arguments: [cliPath, "array", "append", "--key", "tags", "--value", "swift", tempFile]
      ).concatenatedString()
    }
  }
}
