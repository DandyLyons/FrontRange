//
//  SearchTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 12/6/25.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct SearchTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../.build/debug/fr"

  let exampleFilesDir = Bundle.module
    .url(forResource: "ExampleFiles", withExtension: nil)!
    .path()

  // MARK: - Basic Equality Tests

  @Test func `Search finds files where draft equals true`() async throws {
    // swift run fr search 'draft == `true`' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true`", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
    #expect(!output.contains("test-draft-false.md"))
    #expect(!output.contains("test-aliases.md"))
  }

  @Test func `Search finds files where draft equals false`() async throws {
    // swift run fr search 'draft == `false`' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `false`", exampleFilesDir]
    ).concatenatedString()

    #expect(!output.contains("test-draft-true.md"))
    #expect(output.contains("test-draft-false.md"))
    #expect(output.contains("test-aliases.md"))
  }

  // MARK: - Array Contains Tests

  @Test func `Search finds files where aliases contains Blue`() async throws {
    // swift run fr search 'contains(aliases, `"Blue"`)' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "contains(aliases, `\"Blue\"`)", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-aliases.md"))
    #expect(!output.contains("test-draft-true.md"))
    #expect(!output.contains("test-draft-false.md"))
  }

  @Test func `Search finds files where tags contains swift`() async throws {
    // swift run fr search 'contains(tags, `"swift"`)' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "contains(tags, `\"swift\"`)", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
    #expect(output.contains("test-draft-false.md"))
  }

  // MARK: - No Matches Tests

  @Test func `Search shows helpful message when no files match`() async throws {
    // swift run fr search 'contains(aleases, `"Blue"`)' ./ExampleFiles/
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "search", "contains(aleases, `\"Blue\"`)", exampleFilesDir]
    )

    // No results in stdout
    #expect(stdout.isEmpty)

    // Helpful message in stderr
    #expect(stderr.contains("No files matched the query"))
    #expect(stderr.contains("contains(aleases, `\"Blue\"`)"))
    #expect(stderr.contains("Searched"))
    #expect(stderr.contains("file(s)"))
  }

  /// Helper to run command and separate stdout from stderr
  private func runAndSeparateOutput(arguments: [String]) async throws -> (stdout: String, stderr: String) {
    let stream = commandRunner.run(arguments: arguments)
    var stdout = ""
    var stderr = ""

    for try await event in stream {
      switch event.pipeline {
      case .standardOutput:
        if let str = event.string(encoding: .utf8) {
          stdout.append(str)
        }
      case .standardError:
        if let str = event.string(encoding: .utf8) {
          stderr.append(str)
        }
      }
    }

    return (stdout, stderr)
  }

  @Test func `Search with nonexistent key returns no matches`() async throws {
    // swift run fr search 'nonexistent == `"value"`' ./ExampleFiles/
    let stderr = try await commandRunner.run(
      arguments: [cliPath, "search", "nonexistent == `\"value\"`", exampleFilesDir]
    ).concatenatedString(including: [.standardError])

    #expect(stderr.contains("No files matched the query"))
  }

  // MARK: - Output Format Tests

  @Test func `Search outputs JSON format`() async throws {
    // swift run fr search 'draft == `true`' --format json ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true`", "--format", "json", exampleFilesDir]
    ).concatenatedString()

    // Should be valid JSON array
    #expect(output.hasPrefix("["))
    #expect(output.hasSuffix("]\n") || output.hasSuffix("]"))
    #expect(output.contains("test-draft-true.md"))
  }

  @Test func `Search outputs YAML format`() async throws {
    // swift run fr search 'draft == `true`' --format yaml ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true`", "--format", "yaml", exampleFilesDir]
    ).concatenatedString()

    // YAML format should start with dash
    #expect(output.hasPrefix("- "))
    #expect(output.contains("test-draft-true.md"))
  }

  @Test func `Search outputs plain text format by default`() async throws {
    // swift run fr search 'draft == `true`' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true`", exampleFilesDir]
    ).concatenatedString()

    // Plain text should just be file paths, one per line
    #expect(!output.hasPrefix("["))
    #expect(!output.hasPrefix("- "))
    #expect(output.contains("test-draft-true.md"))

    // Should end with newline
    #expect(output.hasSuffix("\n"))
  }

  // MARK: - Complex Query Tests

  @Test func `Search with AND condition`() async throws {
    // swift run fr search 'draft == `false` && contains(tags, `"swift"`)' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `false` && contains(tags, `\"swift\"`)", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-false.md"))
    #expect(!output.contains("test-draft-true.md"))
    #expect(!output.contains("test-aliases.md"))
  }

  @Test func `Search with OR condition`() async throws {
    // swift run fr search 'draft == `true` || contains(aliases, `"Blue"`)' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true` || contains(aliases, `\"Blue\"`)", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
    #expect(output.contains("test-aliases.md"))
    #expect(!output.contains("test-draft-false.md"))
  }

  // MARK: - Error Handling Tests

  @Test func `Search with invalid JMESPath expression shows error`() async throws {
    // Invalid JMESPath will cause the command to fail with a validation error
    // swift run fr search 'invalid {{{{ syntax' ./ExampleFiles/
    let stream = commandRunner.run(arguments: [cliPath, "search", "invalid {{{{ syntax", exampleFilesDir])
    var stderr = ""
    var didFail = false

    do {
      for try await event in stream {
        switch event.pipeline {
        case .standardError:
          if let str = event.string(encoding: .utf8) {
            stderr.append(str)
          }
        case .standardOutput:
          break
        }
      }
    } catch {
      didFail = true
    }

    // The command should fail
    #expect(didFail, "Expected command to fail with invalid JMESPath expression")

    // Verify the error message in stderr contains helpful information
    #expect(stderr.contains("Invalid JMESPath expression"))
    #expect(stderr.contains("invalid {{{{ syntax"))
    #expect(stderr.contains("Unexpected token"))
  }

  // MARK: - Single File Tests

  @Test func `Search works with single file path`() async throws {
    let singleFile = "\(exampleFilesDir)/test-draft-true.md"
    // swift run fr search 'draft == `true`' ./ExampleFiles/test-draft-true.md
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "draft == `true`", singleFile]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
  }

  @Test func `Search single file that does not match returns no results`() async throws {
    let singleFile = "\(exampleFilesDir)/test-draft-false.md"
    // swift run fr search 'draft == `true`' ./ExampleFiles/test-draft-false.md
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "search", "draft == `true`", singleFile]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files matched"))
    #expect(stderr.contains("Searched 1 file(s)"))
  }

  // MARK: - Extension Filtering Tests

  @Test func `Search respects extension filtering`() async throws {
    // Only search .md files (default behavior)
    // swift run fr search 'bool == `true`' ./ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "search", "bool == `true`", exampleFilesDir]
    ).concatenatedString()

    // Should find Example.md which has bool: true
    #expect(output.contains("Example.md"))
  }
}
