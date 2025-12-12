//
//  ReplaceToolTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-12.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite(.serialized) struct ReplaceToolTests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  @Test func replaceWithJSON() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let jsonData = """
      {
        "title": "New Title",
        "author": "New Author",
        "tags": ["replaced", "json"]
      }
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(jsonData),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Replaced front matter"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the front matter was replaced
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("title: New Title"))
    #expect(updatedContent.contains("author: New Author"))
    #expect(updatedContent.contains("- replaced"))
    #expect(updatedContent.contains("- json"))
    
    // Verify old values are gone
    #expect(!updatedContent.contains("string:"))
    #expect(!updatedContent.contains("Hello, World!"))
  }

  @Test func replaceWithYAML() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let yamlData = """
      title: YAML Title
      author: YAML Author
      tags:
        - yaml
        - test
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(yamlData),
        "format": .string("yaml")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Replaced front matter"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the front matter was replaced
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("title: YAML Title"))
    #expect(updatedContent.contains("author: YAML Author"))
    #expect(updatedContent.contains("- yaml"))
  }

  @Test func replaceWithPlist() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let plistData = """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>title</key>
        <string>Plist Title</string>
        <key>author</key>
        <string>Plist Author</string>
      </dict>
      </plist>
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(plistData),
        "format": .string("plist")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Replaced front matter"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the front matter was replaced
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("title: Plist Title"))
    #expect(updatedContent.contains("author: Plist Author"))
  }

  @Test func replaceWithInvalidFormat() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string("{}"),
        "format": .string("invalid")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Invalid format"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func replaceWithArrayData() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let arrayData = """
      ["item1", "item2", "item3"]
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(arrayData),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("must be a dictionary/mapping"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func replaceWithScalarData() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let scalarData = "\"just a string\""

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(scalarData),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("must be a dictionary/mapping"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func replaceWithMalformedJSON() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let malformedData = """
      {
        "title": "Missing closing brace"
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(malformedData),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Error"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func replaceWithMalformedYAML() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let malformedData = """
      title: Valid Title
      author: [invalid: nested: structure
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(malformedData),
        "format": .string("yaml")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("Error"))
    } else {
      Issue.record("Expected text content")
    }
  }

  @Test func replaceWithInvalidPath() async throws {
    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string("/nonexistent/file.md"),
        "data": .string("{}"),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError == true)
  }

  @Test func replaceWithMissingPathParameter() async throws {
    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "data": .string("{}"),
        "format": .string("json")
      ]
    )

    do {
      let result = try await runReplaceTool(params: params)
      #expect(result.isError == true)
      if case .text(let text) = result.content[0] {
        #expect(text.contains("Missing required parameter: path"))
      }
    } catch {
      // MCPError is also acceptable
      #expect(error.localizedDescription.contains("Missing required parameter: path"))
    }
  }

  @Test func replaceWithMissingDataParameter() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "format": .string("json")
      ]
    )

    do {
      let result = try await runReplaceTool(params: params)
      #expect(result.isError == true)
      if case .text(let text) = result.content[0] {
        #expect(text.contains("Missing required parameter: data"))
      }
    } catch {
      // MCPError is also acceptable
      #expect(error.localizedDescription.contains("Missing required parameter: data"))
    }
  }

  @Test func replaceDefaultsToJSON() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    let jsonData = """
      {
        "title": "Default Format Test"
      }
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(jsonData)
        // Note: no format parameter, should default to JSON
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError != true)

    if case .text(let text) = result.content[0] {
      #expect(text.contains("✓ Replaced front matter"))
    } else {
      Issue.record("Expected text content")
    }

    // Verify the front matter was replaced
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains("title: Default Format Test"))
  }

  @Test func replacePreservesBodyContent() async throws {
    let tempPath = try copyIntoTempFile(source: exampleMDPath)
    defer { try? FileManager.default.removeItem(atPath: tempPath) }

    // Read original body content
    let originalContent = try String(contentsOfFile: exampleMDPath, encoding: .utf8)
    let bodyStartIndex = originalContent.range(of: "---\n", options: .backwards)?.upperBound
    let originalBody = bodyStartIndex.map { String(originalContent[$0...]) } ?? ""

    let jsonData = """
      {
        "new": "frontmatter"
      }
      """

    let params = makeCallToolParameters(
      name: "replace",
      arguments: [
        "path": .string(tempPath),
        "data": .string(jsonData),
        "format": .string("json")
      ]
    )

    let result = try await runReplaceTool(params: params)
    #expect(result.isError != true)

    // Verify the body content is preserved
    let updatedContent = try String(contentsOfFile: tempPath, encoding: .utf8)
    #expect(updatedContent.contains(originalBody.trimmingCharacters(in: .whitespacesAndNewlines)))
  }
}
