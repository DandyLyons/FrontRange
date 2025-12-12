//
//  DumpTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct DumpTests {
  let testDumpPath = Bundle.module
    .url(forResource: "test-dump", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()

  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../.build/debug/fr"

  @Test func `Dump command with JSON format (default)` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "json"],
    ).concatenatedString()

    // JSON should be valid and contain all keys
    #expect(output.contains("\"title\""))
    #expect(output.contains("\"draft\""))
    #expect(output.contains("\"tags\""))
    #expect(output.contains("\"author\""))
    #expect(output.contains("\"date\""))
    #expect(output.contains("\"rating\""))
    #expect(output.contains("\"Claude\""))
    #expect(output.contains("true"))
    #expect(output.contains("4.5"))
  }

  @Test func `Dump command with YAML format` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "yaml"],
    ).concatenatedString()

    // Check output contains all expected keys and values (Yams adds trailing newlines)
    #expect(output.contains("title: Test Post"))
    #expect(output.contains("draft: true"))
    #expect(output.contains("tags:"))
    #expect(output.contains("- swift"))
    #expect(output.contains("- cli"))
    #expect(output.contains("author: Claude"))
    #expect(output.contains("date: 2025-12-11"))
    #expect(output.contains("rating: 4.5"))
  }

  @Test func `Dump command with YAML and delimiters` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "yaml", "--include-delimiters"],
    ).concatenatedString()

    // Should start with ---
    #expect(output.hasPrefix("---\n"))
    // Should end with ---
    #expect(output.hasSuffix("---\n"))
    // Should contain the front matter
    #expect(output.contains("title: Test Post"))
  }

  @Test func `Dump command with raw format` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "raw"],
    ).concatenatedString()

    // Raw should be same as YAML (check contents rather than exact format)
    #expect(output.contains("title: Test Post"))
    #expect(output.contains("draft: true"))
    #expect(output.contains("tags:"))
    #expect(output.contains("- swift"))
    #expect(output.contains("- cli"))
    #expect(output.contains("author: Claude"))
    #expect(output.contains("date: 2025-12-11"))
    #expect(output.contains("rating: 4.5"))
  }

  @Test func `Dump command with plist format` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "plist"],
    ).concatenatedString()

    // Should be valid plist XML
    #expect(output.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
    #expect(output.contains("<!DOCTYPE plist"))
    #expect(output.contains("<plist version=\"1.0\">"))
    #expect(output.contains("<dict>"))
    #expect(output.contains("<key>title</key>"))
    #expect(output.contains("<string>Test Post</string>"))
    #expect(output.contains("<key>draft</key>"))
    #expect(output.contains("<true/>"))
    #expect(output.contains("<key>rating</key>"))
    #expect(output.contains("<real>4.5</real>"))
    #expect(output.contains("</plist>"))
  }

  @Test func `Dump command with alias 'd'` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "d", testDumpPath, "--format", "yaml"],
    ).concatenatedString()

    // Should work with alias
    #expect(output.contains("title: Test Post"))
    #expect(output.contains("draft: true"))
  }

  @Test func `Dump command with Example.md` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", examplePath, "--format", "yaml"],
    ).concatenatedString()

    // Should dump the entire front matter from Example.md
    #expect(output.contains("bool: true"))
    #expect(output.contains("int: 42"))
    #expect(output.contains("float: 3.14"))
    #expect(output.contains("string: \"Hello, World!\"")) // String values are quoted in YAML
    #expect(output.contains("list:"))
    #expect(output.contains("- item1"))
    #expect(output.contains("dict:"))
    #expect(output.contains("key1: value1"))
  }

  @Test func `Dump single file has no header` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--format", "yaml"],
    ).concatenatedString()

    // Single file should NOT have cat-style header
    #expect(!output.contains("==>"))
    #expect(!output.contains("<=="))
    // But should contain the content
    #expect(output.contains("title: Test Post"))
  }

  @Test func `Dump multiple files has cat-style headers` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "yaml"],
    ).concatenatedString()

    // Should have cat-style headers for each file
    #expect(output.contains("==> \(testDumpPath) <=="))
    #expect(output.contains("==> \(examplePath) <=="))

    // Should contain content from both files
    #expect(output.contains("title: Test Post"))
    #expect(output.contains("bool: true"))

    // Should have empty line separation between files
    let lines = output.split(separator: "\n", omittingEmptySubsequences: false)
    // Find the index of the first header
    let firstHeaderIndex = lines.firstIndex { $0.contains("==> \(testDumpPath) <==") }
    #expect(firstHeaderIndex != nil)
  }

  @Test func `Dump multiple files separates with empty lines` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "yaml"],
    ).concatenatedString()

    // Verify that output contains empty line between the two file outputs
    // The pattern should be: content from file 1, then empty line, then header for file 2
    let lines = output.split(separator: "\n", omittingEmptySubsequences: false)

    // Find the second header
    let secondHeaderIndex = lines.firstIndex { $0.contains("==> \(examplePath) <==") }
    #expect(secondHeaderIndex != nil)

    if let idx = secondHeaderIndex, idx > 0 {
      // The line before the second header should be empty
      #expect(lines[idx - 1].isEmpty)
    }
  }

  @Test func `Dump multiple files with multi-format json` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--multi-format", "json"],
    ).concatenatedString()

    // Should be valid JSON array
    #expect(output.contains("["))
    #expect(output.contains("]"))

    // Should contain path and frontMatter keys
    #expect(output.contains("\"path\""))
    #expect(output.contains("\"frontMatter\""))

    // Should contain both file paths (paths are escaped in JSON with \/)
    #expect(output.contains("test-dump.md"))
    #expect(output.contains("Example.md"))

    // Should NOT have cat-style headers
    #expect(!output.contains("==>"))
  }

  @Test func `Dump multiple files with multi-format yaml` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--multi-format", "yaml"],
    ).concatenatedString()

    // Should contain YAML array syntax
    #expect(output.contains("- frontMatter:") || output.contains("- path:"))
    #expect(output.contains("frontMatter:"))
    #expect(output.contains("path:"))

    // Should contain both file paths
    #expect(output.contains("test-dump.md"))
    #expect(output.contains("Example.md"))

    // Should NOT have cat-style headers
    #expect(!output.contains("==>"))
  }

  @Test func `Dump mixed format - yaml content in json structure` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "yaml", "--multi-format", "json"],
    ).concatenatedString()

    // Should be JSON structure
    #expect(output.contains("["))
    #expect(output.contains("\"path\""))
    #expect(output.contains("\"frontMatter\""))

    // Front matter should be YAML strings (escaped in JSON)
    #expect(output.contains("title:"))
    #expect(output.contains("\\n")) // YAML newlines escaped in JSON strings
  }

  @Test func `Single file ignores multi-format flag` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, "--multi-format", "json"],
    ).concatenatedString()

    // Should NOT be wrapped in array structure
    #expect(!output.contains("\"path\""))
    #expect(!output.contains("\"frontMatter\""))
    #expect(!output.hasPrefix("["))

    // Should just output the front matter directly
    #expect(output.contains("\"title\""))
    #expect(output.contains("\"draft\""))
  }

  @Test func `Dump multiple files with multi-format plist` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--multi-format", "plist"],
    ).concatenatedString()

    // Should be valid plist XML
    #expect(output.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
    #expect(output.contains("<!DOCTYPE plist"))
    #expect(output.contains("<plist version=\"1.0\">"))
    #expect(output.contains("<array>"))

    // Should contain path and frontMatter keys
    #expect(output.contains("<key>path</key>"))
    #expect(output.contains("<key>frontMatter</key>"))

    // Should contain both file paths
    #expect(output.contains(testDumpPath))
    #expect(output.contains(examplePath))
  }

  @Test func `Dump multiple files with default multi-format uses cat style` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath],
    ).concatenatedString()

    // Should have cat-style headers (default behavior)
    #expect(output.contains("==> \(testDumpPath) <=="))
    #expect(output.contains("==> \(examplePath) <=="))
  }

  @Test func `Dump with matching formats embeds structured data - JSON` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "json", "--multi-format", "json"],
    ).concatenatedString()

    // Should be valid JSON array
    #expect(output.contains("["))
    #expect(output.contains("]"))

    // frontMatter should be embedded objects, not escaped strings
    // If it were a string, we'd see \" and \\n escapes
    // With embedded objects, we see raw JSON structure
    #expect(output.contains("\"frontMatter\""))

    // Check that frontMatter contains actual JSON objects (not escaped strings)
    // We should see "title" directly in frontMatter, not "\"title\""
    #expect(output.contains("\"title\""))

    // Should NOT have escaped newlines like \\n (which appear when JSON is stringified)
    #expect(!output.contains("\\\\n"))
  }

  @Test func `Dump with matching formats embeds structured data - YAML` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "yaml", "--multi-format", "yaml"],
    ).concatenatedString()

    // Should contain YAML array structure
    #expect(output.contains("- frontMatter:"))
    #expect(output.contains("path:"))

    // frontMatter should be embedded structure, not quoted string
    // If embedded, we see nested YAML like "title: Test Post"
    // If string, we'd see "frontMatter: \"title: Test Post\\n...\""
    #expect(output.contains("title:"))

    // Check for nested structure indicators (indentation)
    #expect(output.contains("    ") || output.contains("  "))
  }

  @Test func `Dump with non-matching formats uses strings` () async throws {
    let examplePath = Bundle.module
      .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
      .path()

    let output = try await commandRunner.run(
      arguments: [cliPath, "dump", testDumpPath, examplePath, "--format", "yaml", "--multi-format", "json"],
    ).concatenatedString()

    // Should be JSON structure
    #expect(output.contains("["))
    #expect(output.contains("\"frontMatter\""))

    // frontMatter should be a string (YAML content escaped in JSON)
    // We should see escaped newlines \\n
    #expect(output.contains("\\n"))
  }
}
