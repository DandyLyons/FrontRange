//
//  CSVBulk.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-13.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit
import SwiftCSV

extension FrontRangeCLIEntry {
  struct CSVBulk: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "csv-bulk",
      abstract: "Apply bulk mutations from a CSV file",
      discussion: """
        Apply multiple front matter operations defined in a CSV file.

        CSV FORMAT:
          The CSV file must have the following columns (header row required):
          - file_path: Path to the file to modify (relative or absolute)
          - operation: Operation to perform (set, remove, rename)
          - key: The front matter key to operate on
          - value: The value to set (for 'set' operation)
          - new_key: The new key name (for 'rename' operation)

        OPERATIONS:
          - set: Set a key to a value
              Example: posts/post1.md,set,title,New Title,

          - remove: Remove a key from front matter
              Example: posts/post2.md,remove,draft,,

          - rename: Rename a key
              Example: posts/post3.md,rename,old_name,,new_name

        CONFIRMATION:
          By default, you'll be prompted once before applying all operations.
          Use --yes to skip confirmation (useful for automation).

        ERROR HANDLING:
          Errors for individual files are reported but don't stop processing.
          A summary is displayed at the end showing successes and failures.

        Examples:
          # Apply operations from CSV with confirmation
          fr csv-bulk operations.csv

          # Skip confirmation prompt
          fr csv-bulk operations.csv --yes

          # Process with debug output
          fr csv-bulk operations.csv --debug

        SAMPLE CSV:
          file_path,operation,key,value,new_key
          posts/post1.md,set,title,New Title,
          posts/post1.md,set,draft,false,
          posts/post2.md,remove,temporary,,
          posts/post3.md,rename,old_title,,title
        """
    )

    @Argument(help: "Path to the CSV file containing operations")
    var csvPath: Path

    @Flag(name: [.short, .long], help: "Skip confirmation prompt")
    var yes: Bool = false

    @Flag(name: [.short, .long], help: "Enable debug output")
    var debug: Bool = false

    func run() throws {
      printIfDebug("ℹ️ Reading CSV file from '\(csvPath)'")

      // Read and parse CSV
      let csvContent = try csvPath.read(.utf8)
      let csv = try CSV(string: csvContent)

      // Validate CSV has required columns
      let requiredColumns = ["file_path", "operation", "key"]
      let headers = csv.header
      for column in requiredColumns {
        guard headers.contains(column) else {
          throw ValidationError("CSV must contain '\(column)' column. Found: \(headers.joined(separator: ", "))")
        }
      }

      // Parse operations
      let operations = try parseOperations(from: csv)

      guard !operations.isEmpty else {
        print("⚠️  No operations found in CSV file")
        return
      }

      // Show summary
      print("📋 Found \(operations.count) operation(s) to apply")
      if debug {
        for (index, op) in operations.enumerated() {
          print("  \(index + 1). \(op.description)")
        }
      }

      // Confirmation prompt
      if !yes {
        print("\n⚠️  This will modify \(Set(operations.map { $0.filePath }).count) file(s). Continue? (y/n): ", terminator: "")
        fflush(stdout)

        guard let response = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
          print("Cancelled (no input).")
          return
        }

        guard response == "y" || response == "yes" else {
          print("Cancelled.")
          return
        }
      }

      // Apply operations
      print("\n🚀 Applying operations...")
      var successes = 0
      var failures: [(Operation, Error)] = []

      for operation in operations {
        do {
          try applyOperation(operation)
          successes += 1
          print("✓ \(operation.filePath): \(operation.shortDescription)")
        } catch {
          failures.append((operation, error))
          print("✗ \(operation.filePath): \(operation.shortDescription) - \(error.localizedDescription)")
        }
      }

      // Summary
      print("\n📊 Summary:")
      print("  ✓ Successful: \(successes)")
      print("  ✗ Failed: \(failures.count)")

      if !failures.isEmpty && debug {
        print("\nFailed operations:")
        for (operation, error) in failures {
          print("  - \(operation.description)")
          print("    Error: \(error.localizedDescription)")
        }
      }
    }

    private func parseOperations(from csv: CSV) throws -> [Operation] {
      var operations: [Operation] = []

      for (index, row) in csv.namedRows.enumerated() {
        let lineNumber = index + 2 // +1 for 0-index, +1 for header row

        guard let filePath = row["file_path"], !filePath.isEmpty else {
          printIfDebug("⚠️  Skipping row \(lineNumber): missing file_path")
          continue
        }

        guard let operationType = row["operation"], !operationType.isEmpty else {
          printIfDebug("⚠️  Skipping row \(lineNumber): missing operation")
          continue
        }

        guard let key = row["key"], !key.isEmpty else {
          printIfDebug("⚠️  Skipping row \(lineNumber): missing key")
          continue
        }

        let value = row["value"] ?? ""
        let newKey = row["new_key"] ?? ""

        let operation: Operation
        switch operationType.lowercased() {
        case "set":
          guard !value.isEmpty else {
            throw ValidationError("Row \(lineNumber): 'set' operation requires a value")
          }
          operation = .set(filePath: filePath, key: key, value: value)

        case "remove":
          operation = .remove(filePath: filePath, key: key)

        case "rename":
          guard !newKey.isEmpty else {
            throw ValidationError("Row \(lineNumber): 'rename' operation requires new_key")
          }
          operation = .rename(filePath: filePath, oldKey: key, newKey: newKey)

        default:
          throw ValidationError("Row \(lineNumber): unknown operation '\(operationType)'. Must be: set, remove, or rename")
        }

        operations.append(operation)
      }

      return operations
    }

    private func applyOperation(_ operation: Operation) throws {
      let path = Path(operation.filePath)

      guard path.exists else {
        throw ValidationError("File not found: \(operation.filePath)")
      }

      let content = try path.read(.utf8)
      var doc = try FrontMatteredDoc(parsing: content)

      switch operation {
      case .set(_, let key, let value):
        doc.setValue(value, forKey: key)

      case .remove(_, let key):
        try doc.remove(key: key)

      case .rename(_, let oldKey, let newKey):
        try doc.renameKey(from: oldKey, to: newKey)
      }

      let updatedContent = try doc.render()
      try path.write(updatedContent)
    }

    private func printIfDebug(_ message: String) {
      if debug {
        print(message)
      }
    }
  }
}

// MARK: - Operation Type

enum Operation {
  case set(filePath: String, key: String, value: String)
  case remove(filePath: String, key: String)
  case rename(filePath: String, oldKey: String, newKey: String)

  var filePath: String {
    switch self {
    case .set(let path, _, _): return path
    case .remove(let path, _): return path
    case .rename(let path, _, _): return path
    }
  }

  var shortDescription: String {
    switch self {
    case .set(_, let key, let value):
      return "set \(key)=\(value)"
    case .remove(_, let key):
      return "remove \(key)"
    case .rename(_, let oldKey, let newKey):
      return "rename \(oldKey)→\(newKey)"
    }
  }

  var description: String {
    switch self {
    case .set(let path, let key, let value):
      return "\(path): set \(key)=\(value)"
    case .remove(let path, let key):
      return "\(path): remove \(key)"
    case .rename(let path, let oldKey, let newKey):
      return "\(path): rename \(oldKey)→\(newKey)"
    }
  }
}
