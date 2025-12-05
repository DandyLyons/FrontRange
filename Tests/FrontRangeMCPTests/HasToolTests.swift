//
//  HasToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct HasToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func hasExistingKey() async throws {
    let params = makeCallToolParameters(
      name: "has",
      arguments: [
        "key": .string("string"),
        "paths": .array([.string(exampleMDPath)])
      ]
    )

    let result = try await runHasTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Files containing key 'string'"))
      #expect(text.contains(exampleMDPath))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func hasMissingKey() async throws {
    let params = makeCallToolParameters(
      name: "has",
      arguments: [
        "key": .string("nonexistent"),
        "paths": .array([.string(exampleMDPath)])
      ]
    )

    let result = try await runHasTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Files NOT containing key 'nonexistent'"))
      #expect(text.contains(exampleMDPath))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func hasMultipleFiles() async throws {
    let tempPath = try createTempFile(withContent: """
      ---
      different: value
      ---
      Content
      """)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "has",
      arguments: [
        "key": .string("string"),
        "paths": .array([.string(exampleMDPath), .string(tempPath)])
      ]
    )

    let result = try await runHasTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Files containing key 'string'"))
      #expect(text.contains(exampleMDPath))
      #expect(text.contains("Files NOT containing key 'string'"))
      #expect(text.contains(tempPath))
    } else {
      Issue.record("Expected text content")
    }
  }
}
