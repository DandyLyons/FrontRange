//
//  GetToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct GetToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func getExistingKey() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("string"),
        "path": .string(exampleMDPath),
        "format": .string("json")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError != true)
    #expect(result.content.count == 1)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Hello, World!"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func getExistingKeyYAMLFormat() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("string"),
        "path": .string(exampleMDPath),
        "format": .string("yaml")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError != true)
    #expect(result.content.count == 1)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Hello, World!"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func getMissingKey() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("nonexistent"),
        "path": .string(exampleMDPath),
        "format": .string("json")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError == true)
    #expect(result.content.count == 1)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("not found"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func getWithMissingPath() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("string"),
        "path": .string("/nonexistent/file.md"),
        "format": .string("json")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError == true)
  }

  @Test func getIntegerValue() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("int"),
        "path": .string(exampleMDPath),
        "format": .string("json")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("42"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func getBooleanValue() async throws {
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("bool"),
        "path": .string(exampleMDPath),
        "format": .string("json")
      ]
    )

    let result = try await runGetTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("true"))
    } else {
      Issue.record("Expected text content")
    }
  }
}
