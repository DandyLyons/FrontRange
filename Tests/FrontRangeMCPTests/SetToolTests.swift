//
//  SetToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct SetToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func setExistingKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "set",
      arguments: [
        "key": .string("string"),
        "value": .string("Updated Value"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runSetTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Updated"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the file was actually updated
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("Updated Value"))
  }

  @Test func setNewKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "set",
      arguments: [
        "key": .string("newkey"),
        "value": .string("New Value"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runSetTool(params: params)
    #expect(result.isError != true)

    // Verify the new key was added
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("newkey"))
    #expect(updatedContent.contains("New Value"))
  }

  @Test func setMultipleFiles() async throws {
    let tempPath1 = try copyIntoTempFile(source: exampleMDPath)
    let tempPath2 = try copyIntoTempFile(source: exampleMDPath)
    defer {
      try? FileManager.default.removeItem(atPath: tempPath1)
      try? FileManager.default.removeItem(atPath: tempPath2)
    }

    let params = makeCallToolParameters(
      name: "set",
      arguments: [
        "key": .string("batch"),
        "value": .string("Batch Update"),
        "paths": .array([.string(tempPath1), .string(tempPath2)])
      ]
    )

    let result = try await runSetTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Updated"))
      // Should have 2 success messages
      let lines = text.components(separatedBy: "\n")
      let successLines = lines.filter { $0.contains("✓ Updated") }
      #expect(successLines.count == 2)
    } else {
      Issue.record("Expected text content")
    }

    // Verify both files were updated
    let content1 = try String(contentsOfFile: tempPath1, encoding: .utf8)
    let content2 = try String(contentsOfFile: tempPath2, encoding: .utf8)
    #expect(content1.contains("Batch Update"))
    #expect(content2.contains("Batch Update"))
  }

  @Test func setWithInvalidPath() async throws {
    let params = makeCallToolParameters(
      name: "set",
      arguments: [
        "key": .string("string"),
        "value": .string("Value"),
        "paths": .array([.string("/nonexistent/file.md")])
      ]
    )

    let result = try await runSetTool(params: params)
    #expect(result.isError != true) // Tool handles errors gracefully

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✗ Error"))
    } else {
      Issue.record("Expected text content")
    }
  }
}
