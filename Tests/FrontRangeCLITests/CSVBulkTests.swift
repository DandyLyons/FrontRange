//
//  CSVBulkTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-13.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct CSVBulkTests {
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../.build/debug/fr"

  // Helper to create temp file with front matter
  func createTempFileWithFrontMatter(name: String? = nil) throws -> String {
    let fileName = name ?? "test-csvbulk-\(UUID()).md"
    let tempFile = NSTemporaryDirectory() + fileName
    let content = """
    ---
    title: Original Title
    draft: true
    author: Original Author
    status: draft
    ---

    This is the body content.
    """
    try content.write(toFile: tempFile, atomically: true, encoding: .utf8)
    return tempFile
  }

  // Helper to create CSV file
  func createCSVFile(withContent content: String) throws -> String {
    let tempFile = NSTemporaryDirectory() + "operations-\(UUID()).csv"
    try content.write(toFile: tempFile, atomically: true, encoding: .utf8)
    return tempFile
  }

  @Test func `CSV bulk set operation updates front matter` () async throws {
    let testFile = try createTempFileWithFrontMatter(name: "test-set.md")
    defer { try? FileManager.default.removeItem(atPath: testFile) }

    let csvContent = """
    file_path,operation,key,value,new_key
    \(testFile),set,title,New Title,
    \(testFile),set,draft,false,
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // Run with --yes to skip confirmation
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])

    var stdout = ""
    for try await event in stream {
      if event.pipeline == .standardOutput, let str = event.string(encoding: .utf8) {
        stdout.append(str)
      }
    }

    // Verify output mentions success
    #expect(stdout.contains("Successful: 2"))

    // Verify file was updated
    let updatedContent = try String(contentsOfFile: testFile, encoding: .utf8)
    #expect(updatedContent.contains("title: New Title"))
    #expect(updatedContent.contains("draft: false"))
  }

  @Test func `CSV bulk remove operation removes key` () async throws {
    let testFile = try createTempFileWithFrontMatter(name: "test-remove.md")
    defer { try? FileManager.default.removeItem(atPath: testFile) }

    let csvContent = """
    file_path,operation,key,value,new_key
    \(testFile),remove,draft,,
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // Run with --yes to skip confirmation
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])

    var stdout = ""
    for try await event in stream {
      if event.pipeline == .standardOutput, let str = event.string(encoding: .utf8) {
        stdout.append(str)
      }
    }

    // Verify output mentions success
    #expect(stdout.contains("Successful: 1"))

    // Verify file was updated
    let updatedContent = try String(contentsOfFile: testFile, encoding: .utf8)
    #expect(!updatedContent.contains("draft:"))
  }

  @Test func `CSV bulk rename operation renames key` () async throws {
    let testFile = try createTempFileWithFrontMatter(name: "test-rename.md")
    defer { try? FileManager.default.removeItem(atPath: testFile) }

    let csvContent = """
    file_path,operation,key,value,new_key
    \(testFile),rename,status,,state
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // Run with --yes to skip confirmation
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])

    var stdout = ""
    for try await event in stream {
      if event.pipeline == .standardOutput, let str = event.string(encoding: .utf8) {
        stdout.append(str)
      }
    }

    // Verify output mentions success
    #expect(stdout.contains("Successful: 1"))

    // Verify file was updated
    let updatedContent = try String(contentsOfFile: testFile, encoding: .utf8)
    #expect(!updatedContent.contains("status:"))
    #expect(updatedContent.contains("state: draft"))
  }

  @Test func `CSV bulk error when CSV missing required column` () async throws {
    let csvContent = """
    file_path,operation
    test.md,set
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // This command should fail
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])
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
    #expect(stderr.contains("must contain 'key' column"))
  }

  @Test func `CSV bulk processes multiple files` () async throws {
    let testFile1 = try createTempFileWithFrontMatter(name: "test-multi-1.md")
    let testFile2 = try createTempFileWithFrontMatter(name: "test-multi-2.md")
    defer {
      try? FileManager.default.removeItem(atPath: testFile1)
      try? FileManager.default.removeItem(atPath: testFile2)
    }

    let csvContent = """
    file_path,operation,key,value,new_key
    \(testFile1),set,title,File 1 Title,
    \(testFile2),set,title,File 2 Title,
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // Run with --yes to skip confirmation
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])

    var stdout = ""
    for try await event in stream {
      if event.pipeline == .standardOutput, let str = event.string(encoding: .utf8) {
        stdout.append(str)
      }
    }

    // Verify both operations succeeded
    #expect(stdout.contains("Successful: 2"))

    // Verify both files were updated
    let content1 = try String(contentsOfFile: testFile1, encoding: .utf8)
    let content2 = try String(contentsOfFile: testFile2, encoding: .utf8)
    #expect(content1.contains("title: File 1 Title"))
    #expect(content2.contains("title: File 2 Title"))
  }

  @Test func `CSV bulk error for unknown operation type` () async throws {
    let testFile = try createTempFileWithFrontMatter()
    defer { try? FileManager.default.removeItem(atPath: testFile) }

    let csvContent = """
    file_path,operation,key,value,new_key
    \(testFile),invalid_op,title,New Title,
    """
    let csvFile = try createCSVFile(withContent: csvContent)
    defer { try? FileManager.default.removeItem(atPath: csvFile) }

    // This command should fail
    let stream = commandRunner.run(arguments: [cliPath, "csv-bulk", csvFile, "--yes"])
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
    #expect(stderr.contains("unknown operation"))
  }
}
