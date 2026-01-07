//
//  SortKeysToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct SortKeysToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func sortKeysAlphabetically() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "sort_keys",
      arguments: [
        "paths": .array([.string(tempPath)]),
        "reverse": .bool(false)
      ]
    )

    let result = try await runSortKeysTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Sorted keys"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify keys are sorted
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    let lines = updatedContent.components(separatedBy: "\n")

    // Find the frontmatter section
    var frontMatterLines: [String] = []
    var inFrontMatter = false
    var frontMatterEndFound = false

    for line in lines {
      if line == "---" {
        if !inFrontMatter {
          inFrontMatter = true
        } else if !frontMatterEndFound {
          frontMatterEndFound = true
          break
        }
      } else if inFrontMatter {
        frontMatterLines.append(line)
      }
    }

    // Extract key names (ignoring nested items)
    let topLevelKeys = frontMatterLines
      .filter { !$0.starts(with: "  ") && $0.contains(":") }
      .compactMap { $0.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces) }

    // Verify all consecutive pairs are sorted
    for i in 0..<(topLevelKeys.count - 1) {
      #expect(topLevelKeys[i] < topLevelKeys[i + 1], "Keys should be sorted: \(topLevelKeys[i]) should come before \(topLevelKeys[i + 1])")
    }
  }

  @Test func sortKeysReverse() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "sort_keys",
      arguments: [
        "paths": .array([.string(tempPath)]),
        "reverse": .bool(true)
      ]
    )

    let result = try await runSortKeysTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Sorted keys"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func sortMultipleFiles() async throws {
    let tempPath1 = try copyIntoTempFile(source: exampleMDPath)
    let tempPath2 = try copyIntoTempFile(source: exampleMDPath)
    defer {
      try? FileManager.default.removeItem(atPath: tempPath1)
      try? FileManager.default.removeItem(atPath: tempPath2)
    }

    let params = makeCallToolParameters(
      name: "sort_keys",
      arguments: [
        "paths": .array([.string(tempPath1), .string(tempPath2)]),
        "reverse": .bool(false)
      ]
    )

    let result = try await runSortKeysTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      let lines = text.components(separatedBy: "\n")
      let successLines = lines.filter { $0.contains("✓ Sorted keys") }
      #expect(successLines.count == 2)
    } else {
      Issue.record("Expected text content")
    }
  }
}
