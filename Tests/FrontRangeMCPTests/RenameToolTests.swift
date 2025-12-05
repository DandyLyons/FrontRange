//
//  RenameToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct RenameToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func renameExistingKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "rename",
      arguments: [
        "key": .string("string"),
        "newKey": .string("renamedString"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runRenameTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Renamed key"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the key was actually renamed
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("renamedString"))
    #expect(!updatedContent.contains("string: \"Hello, World!\""))
    #expect(updatedContent.contains("Hello, World!")) // Value should still be there
  }

  @Test func renameNonexistentKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "rename",
      arguments: [
        "key": .string("nonexistent"),
        "newKey": .string("newname"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runRenameTool(params: params)
    #expect(result.isError != true) // Tool handles errors gracefully

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✗ Error"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func renameMultipleFiles() async throws {
    let tempPath1 = try copyIntoTempFile(source: exampleMDPath)
    let tempPath2 = try copyIntoTempFile(source: exampleMDPath)
    defer {
      try? FileManager.default.removeItem(atPath: tempPath1)
      try? FileManager.default.removeItem(atPath: tempPath2)
    }

    let params = makeCallToolParameters(
      name: "rename",
      arguments: [
        "key": .string("string"),
        "newKey": .string("text"),
        "paths": .array([.string(tempPath1), .string(tempPath2)])
      ]
    )

    let result = try await runRenameTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      let lines = text.components(separatedBy: "\n")
      let successLines = lines.filter { $0.contains("✓ Renamed key") }
      #expect(successLines.count == 2)
    } else {
      Issue.record("Expected text content")
    }
  }
}
