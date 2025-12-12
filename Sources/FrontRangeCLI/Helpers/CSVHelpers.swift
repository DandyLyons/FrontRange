//
//  CSVHelpers.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-12.
//

import Foundation
import FrontRange
import PathKit
import TinyCSV
import Yams

/// Generates CSV output from multiple front-mattered documents
struct CSVGenerator {
  let documents: [(path: String, frontMatter: Yams.Node.Mapping)]
  let strategy: CSVColumnStrategy
  let customColumns: [String]?
  let cellFormat: OutputFormat

  func generate() throws -> String {
    // 1. Determine columns based on strategy
    let columns = try determineColumns()

    // 2. Build CSV rows
    var rows: [[String]] = []

    // Header row
    rows.append(["path"] + columns)

    // Data rows - CRITICAL: iterate through columns, not file's keys
    for (path, frontMatter) in documents {
      var row: [String] = [path]

      for column in columns {
        let cellValue = try extractCellValue(
          frontMatter: frontMatter,
          key: column,
          format: cellFormat
        )
        row.append(cellValue)
      }

      rows.append(row)
    }

    // 3. Encode as CSV using TinyCSV
    let coder = TinyCSV.Coder()
    return coder.encode(csvdata: rows, delimiter: .comma)
  }

  private func determineColumns() throws -> [String] {
    switch strategy {
    case .union:
      return unionColumns()
    case .intersection:
      return intersectionColumns()
    case .custom:
      guard let custom = customColumns, !custom.isEmpty else {
        throw CSVError.customColumnsRequired
      }
      return custom
    }
  }

  private func unionColumns() -> [String] {
    // Collect all unique keys from all documents
    var allKeys = Set<String>()

    for (_, frontMatter) in documents {
      for (key, _) in frontMatter {
        if case .scalar(let scalar) = key {
          allKeys.insert(scalar.string)
        }
      }
    }

    // Sort alphabetically for consistent output
    return allKeys.sorted()
  }

  private func intersectionColumns() -> [String] {
    guard !documents.isEmpty else { return [] }

    // Start with keys from first document
    var commonKeys = Set<String>()
    let (_, firstFrontMatter) = documents[0]

    for (key, _) in firstFrontMatter {
      if case .scalar(let scalar) = key {
        commonKeys.insert(scalar.string)
      }
    }

    // Intersect with keys from all other documents
    for (_, frontMatter) in documents.dropFirst() {
      var docKeys = Set<String>()
      for (key, _) in frontMatter {
        if case .scalar(let scalar) = key {
          docKeys.insert(scalar.string)
        }
      }
      commonKeys.formIntersection(docKeys)
    }

    return commonKeys.sorted()
  }

  private func extractCellValue(
    frontMatter: Yams.Node.Mapping,
    key: String,
    format: OutputFormat
  ) throws -> String {
    let keyNode = Yams.Node.scalar(.init(key))

    guard let valueNode = frontMatter[keyNode] else {
      return ""  // Missing key = empty cell
    }

    // Handle different node types
    switch valueNode {
    case .scalar(let scalar):
      // Simple scalar: return as string
      return scalar.string

    case .sequence, .mapping:
      // Complex type: serialize using the specified format
      return try serializeComplexValue(valueNode, format: format)

    case .alias:
      return ""  // Aliases shouldn't appear in front matter
    }
  }

  private func serializeComplexValue(
    _ node: Yams.Node,
    format: OutputFormat
  ) throws -> String {
    // Serialize nested structures as strings using the specified format
    switch format {
    case .json:
      // Compact JSON (no pretty printing for cells)
      return try node.toJSON(options: [.sortedKeys])
    case .yaml, .raw, .plainString:
      return try Yams.serialize(node: node).trimmingCharacters(in: .whitespacesAndNewlines)
    case .plist:
      return try node.toPlist()
    }
  }
}

enum CSVError: Error, CustomStringConvertible {
  case customColumnsRequired
  case singleFileNotSupported

  var description: String {
    switch self {
    case .customColumnsRequired:
      return "--csv-columns custom requires --csv-custom-columns to be specified"
    case .singleFileNotSupported:
      return "CSV format requires multiple files. Use --format json/yaml/plist for single files."
    }
  }
}
