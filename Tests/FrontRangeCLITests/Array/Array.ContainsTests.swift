//
//  Array.ContainsTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2026-01-08.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct ArrayContainsTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../../.build/debug/fr"

  let exampleFilesDir = Bundle.module
    .url(forResource: "ExampleFiles", withExtension: nil)!
    .path()

  // MARK: - Basic Matching Tests

  @Test func `Array-contains finds files with matching value in tags`() async throws {
    // fr array-contains --key tags --value swift ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "swift", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
    #expect(output.contains("test-draft-false.md"))
    #expect(!output.contains("test-aliases.md"))
  }

  @Test func `Array-contains finds files with matching value in aliases`() async throws {
    // fr array-contains --key aliases --value Blue ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "aliases", "--value", "Blue", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-aliases.md"))
    #expect(!output.contains("test-draft-true.md"))
    #expect(!output.contains("test-draft-false.md"))
  }

  @Test func `Array-contains finds specific value in array with multiple elements`() async throws {
    // fr array-contains --key tags --value programming ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "programming", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
    #expect(!output.contains("test-draft-false.md"))
  }

  // MARK: - No Matches Tests

  @Test func `Array-contains with non-existent value returns no results`() async throws {
    // fr array-contains --key tags --value nonexistent ExampleFiles/
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "nonexistent", exampleFilesDir]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files found"))
    #expect(stderr.contains("tags"))
    #expect(stderr.contains("nonexistent"))
  }

  @Test func `Array-contains with non-existent key returns no results`() async throws {
    // fr array-contains --key nonexistentkey --value anyvalue ExampleFiles/
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "nonexistentkey", "--value", "anyvalue", exampleFilesDir]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files found"))
  }

  // MARK: - Invert Flag Tests

  @Test func `Array-contains invert flag finds files NOT containing value`() async throws {
    // fr array-contains --key tags --value swift --invert ExampleFiles/
    // Note: Files without the "tags" key are skipped, even with --invert
    // Only test-csv-2.md has tags but doesn't contain "swift"
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "swift", "--invert", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-csv-2.md"))
    #expect(!output.contains("test-draft-true.md"))
    #expect(!output.contains("test-draft-false.md"))
    #expect(!output.contains("test-aliases.md"))  // Skipped: no "tags" key
  }

  @Test func `Array-contains invert shows appropriate message when no matches`() async throws {
    // fr array-contains --key tags --value nonexistent --invert ExampleFiles/
    let (stdout, _) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "nonexistent", "--invert", exampleFilesDir]
    )

    // Should find files that don't contain "nonexistent" (all files with tags)
    #expect(!stdout.isEmpty)
    #expect(stdout.contains("test-draft-true.md"))
    #expect(stdout.contains("test-draft-false.md"))
  }

  // MARK: - Case Sensitivity Tests

  @Test func `Array-contains is case-sensitive by default`() async throws {
    // fr array-contains --key aliases --value blue ExampleFiles/
    // "blue" should NOT match "Blue" by default
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "aliases", "--value", "blue", exampleFilesDir]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files found"))
  }

  @Test func `Array-contains case-insensitive comparison with -i flag`() async throws {
    // fr array-contains --key aliases --value blue -i ExampleFiles/
    // "blue" SHOULD match "Blue" with -i flag
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "aliases", "--value", "blue", "-i", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-aliases.md"))
  }

  @Test func `Array-contains case-insensitive with --case-insensitive flag`() async throws {
    // fr array-contains --key aliases --value BLUE --case-insensitive ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "aliases", "--value", "BLUE", "--case-insensitive", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-aliases.md"))
  }

  // MARK: - Output Format Tests

  @Test func `Array-contains outputs JSON by default`() async throws {
    // fr array-contains --key aliases --value Blue ExampleFiles/
    // Default format is JSON (from GlobalOptions)
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "aliases", "--value", "Blue", exampleFilesDir]
    ).concatenatedString()

    // Should be valid JSON array
    #expect(output.contains("["))
    #expect(output.contains("]"))
    #expect(output.contains("test-aliases.md"))
  }

  @Test func `Array-contains outputs plain text format`() async throws {
    // fr array-contains --key tags --value swift --format plainString ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "swift", "--format", "plainString", exampleFilesDir]
    ).concatenatedString()

    // Plain text: one path per line
    #expect(output.contains("test-draft-true.md"))
    #expect(output.contains("test-draft-false.md"))
    let lines = output.split(separator: "\n")
    #expect(lines.count >= 4)  // At least 4 files with tags containing "swift"
  }

  @Test func `Array-contains outputs YAML format`() async throws {
    // fr array-contains --key tags --value swift --format yaml ExampleFiles/
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "swift", "--format", "yaml", exampleFilesDir]
    ).concatenatedString()

    // Should be YAML list format
    #expect(output.contains("- "))
    #expect(output.contains("test-draft-true.md"))
    #expect(output.contains("test-draft-false.md"))
  }

  // MARK: - Edge Cases Tests

  @Test func `Array-contains skips files where value is not an array`() async throws {
    // The "draft" key is a boolean, not an array
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "draft", "--value", "true", exampleFilesDir]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files found"))
  }

  @Test func `Array-contains skips files where value is a string`() async throws {
    // The "title" key is a string, not an array
    let (stdout, stderr) = try await runAndSeparateOutput(
      arguments: [cliPath, "array", "contains", "--key", "title", "--value", "Post", exampleFilesDir]
    )

    #expect(stdout.isEmpty)
    #expect(stderr.contains("No files found"))
  }

  // MARK: - Single File Test

  @Test func `Array-contains works with single file path`() async throws {
    // fr array-contains --key tags --value swift ExampleFiles/test-draft-true.md
    let singleFilePath = "\(exampleFilesDir)/test-draft-true.md"
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "swift", singleFilePath]
    ).concatenatedString()

    #expect(output.contains("test-draft-true.md"))
  }

  // MARK: - Multiple Values Test

  @Test func `Array-contains finds different values in same array key across files`() async throws {
    // Find "tutorial" which only exists in test-draft-false.md
    let output = try await commandRunner.run(
      arguments: [cliPath, "array", "contains", "--key", "tags", "--value", "tutorial", exampleFilesDir]
    ).concatenatedString()

    #expect(output.contains("test-draft-false.md"))
    #expect(!output.contains("test-draft-true.md"))
  }

  // MARK: - Helper Methods

  /// Helper to run command and separate stdout from stderr
  /// Handles non-zero exit codes gracefully (command may exit 1 when no matches found)
  private func runAndSeparateOutput(arguments: [String]) async throws -> (stdout: String, stderr: String) {
    let stream = commandRunner.run(arguments: arguments)
    var stdout = ""
    var stderr = ""

    do {
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
    } catch {
      // Command exited with non-zero code (e.g., exit 1 when no matches)
      // This is expected behavior, so we just return what we collected
    }

    return (stdout, stderr)
  }
}
