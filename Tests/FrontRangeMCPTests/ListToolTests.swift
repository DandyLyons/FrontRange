//
//  ListToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct ListToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func listKeysJSON() async throws {
    let params = makeCallToolParameters(
      name: "list",
      arguments: [
        "path": .string(exampleMDPath),
        "format": .string("json")
      ]
    )

    let result = try await runListTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      // Should contain all the keys from Example.md
      #expect(text.contains("bool"))
      #expect(text.contains("int"))
      #expect(text.contains("float"))
      #expect(text.contains("string"))
      #expect(text.contains("list"))
      #expect(text.contains("dict"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func listKeysYAML() async throws {
    let params = makeCallToolParameters(
      name: "list",
      arguments: [
        "path": .string(exampleMDPath),
        "format": .string("yaml")
      ]
    )

    let result = try await runListTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("bool"))
      #expect(text.contains("int"))
      #expect(text.contains("float"))
      #expect(text.contains("string"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func listWithInvalidPath() async throws {
    let params = makeCallToolParameters(
      name: "list",
      arguments: [
        "path": .string("/nonexistent/file.md"),
        "format": .string("json")
      ]
    )

    let result = try await runListTool(params: params)
    #expect(result.isError == true)
  }
}
