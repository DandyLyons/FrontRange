//
//  RemoveToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct RemoveToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func removeExistingKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "remove",
      arguments: [
        "key": .string("string"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runRemoveTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Removed key"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the key was actually removed
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(!updatedContent.contains("string:"))
    #expect(!updatedContent.contains("Hello, World!"))
  }

  @Test func removeNonexistentKey() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "remove",
      arguments: [
        "key": .string("nonexistent"),
        "paths": .array([.string(tempPath)])
      ]
    )

    let result = try await runRemoveTool(params: params)
    #expect(result.isError != true) // Tool should succeed even if key doesn't exist

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Removed key"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func removeMultipleFiles() async throws {
    let tempPath1 = try copyIntoTempFile(source: exampleMDPath)
    let tempPath2 = try copyIntoTempFile(source: exampleMDPath)
    defer {
      try? FileManager.default.removeItem(atPath: tempPath1)
      try? FileManager.default.removeItem(atPath: tempPath2)
    }

    let params = makeCallToolParameters(
      name: "remove",
      arguments: [
        "key": .string("bool"),
        "paths": .array([.string(tempPath1), .string(tempPath2)])
      ]
    )

    let result = try await runRemoveTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      let lines = text.components(separatedBy: "\n")
      let successLines = lines.filter { $0.contains("✓ Removed key") }
      #expect(successLines.count == 2)
    } else {
      Issue.record("Expected text content")
    }

    // Verify both files were updated
    let content1 = try String(contentsOfFile: tempPath1, encoding: .utf8)
    let content2 = try String(contentsOfFile: tempPath2, encoding: .utf8)
    #expect(!content1.contains("bool:"))
    #expect(!content2.contains("bool:"))
  }
}
