//
//  ReplaceTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct ReplaceTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../.build/debug/fr"

  // Helper to create temp file with front matter
  func createTempFileWithFrontMatter() throws -> String {
    let tempFile = NSTemporaryDirectory() + "test-replace-\(UUID()).md"
    let content = """
    ---
    title: Original Title
    draft: true
    author: Original Author
    ---

    This is the body content.
    """
    try content.write(toFile: tempFile, atomically: true, encoding: .utf8)
    return tempFile
  }

  @Test func `Replace error when both data and from-file specified` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    // This command should fail with validation error
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--data", "{}", "--from-file", "dummy.json", "--format", "json"])
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

    #expect(didFail)
    #expect(stderr.contains("Cannot use both --data and --from-file"))
  }

  @Test func `Replace error when neither option specified` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    // This command should fail with validation error
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--format", "json"])
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

    #expect(didFail)
    #expect(stderr.contains("Must specify either --data or --from-file"))
  }

  @Test func `Replace validation rejects JSON array` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    // This command should fail with validation error
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--data", "[\"item1\", \"item2\"]", "--format", "json"])
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

    #expect(didFail)
    #expect(stderr.contains("must be a dictionary/mapping"))
  }

  @Test func `Replace validation rejects JSON scalar` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    // This command should fail with validation error
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--data", "\"just a string\"", "--format", "json"])
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

    #expect(didFail)
    #expect(stderr.contains("must be a dictionary/mapping"))
  }

  @Test func `Replace validation rejects invalid JSON` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    // This command should fail with validation error
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--data", "{invalid json", "--format", "json"])
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

    #expect(didFail)
    #expect(stderr.contains("Failed to parse"))
  }

  @Test func `Replace validation rejects YAML array` () async throws {
    let tempFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: tempFile) }

    let yamlArray = """
    - item1
    - item2
    """

    // Use --data= syntax (with =) to pass inline YAML that starts with -
    // This prevents ArgumentParser from treating - as a flag
    let stream = commandRunner.run(arguments: [cliPath, "replace", tempFile, "--data=\(yamlArray)", "--format", "yaml"])
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

    #expect(didFail)
    #expect(stderr.contains("must be a dictionary/mapping"))
  }

  @Test func `Replace command has from-file option` () async throws {
    // Verify that the --from-file option is documented in help
    let output = try await commandRunner.run(
      arguments: [cliPath, "replace", "--help"]
    ).concatenatedString()

    // Should document the --from-file option
    #expect(output.contains("--from-file"))
    // Should explain that it reads from a file
    #expect(output.contains("Path to file containing new front matter"))
  }
}
