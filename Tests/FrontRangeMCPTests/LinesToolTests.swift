//
//  LinesToolTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct LinesToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func extractLines() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string(exampleMDPath),
        "start": .int(1),
        "end": .int(5),
        "numbered": .bool(false)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("---"))
      #expect(text.contains("bool:"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func extractLinesWithNumbers() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string(exampleMDPath),
        "start": .int(1),
        "end": .int(3),
        "numbered": .bool(true)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("1:"))
      #expect(text.contains("2:"))
      #expect(text.contains("3:"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func extractSingleLine() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string(exampleMDPath),
        "start": .int(2),
        "end": .int(2),
        "numbered": .bool(false)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("bool:"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func extractLinesInvalidRange() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string(exampleMDPath),
        "start": .int(0),
        "end": .int(5),
        "numbered": .bool(false)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("greater than 0"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func extractLinesEndBeforeStart() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string(exampleMDPath),
        "start": .int(10),
        "end": .int(5),
        "numbered": .bool(false)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("greater than or equal to start"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func extractLinesWithInvalidPath() async throws {
    let params = makeCallToolParameters(
      name: "lines",
      arguments: [
        "path": .string("/nonexistent/file.md"),
        "start": .int(1),
        "end": .int(5),
        "numbered": .bool(false)
      ]
    )

    let result = try await runLinesTool(params: params)
    #expect(result.isError == true)
  }
}
