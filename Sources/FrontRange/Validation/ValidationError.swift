//
//  ValidationError.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation

/// Errors that can occur during schema validation
public enum ValidationError: Error, CustomStringConvertible {
  case schemaNotFound(String)
  case schemaLoadFailed(String, underlyingError: Error)
  case schemaInvalid(String)
  case validationFailed(violations: [ValidationViolation])

  public var description: String {
    switch self {
    case .schemaNotFound(let path):
      return "Schema not found: \(path)"
    case .schemaLoadFailed(let path, let error):
      return "Failed to load schema from '\(path)': \(error.localizedDescription)"
    case .schemaInvalid(let message):
      return "Invalid schema: \(message)"
    case .validationFailed(let violations):
      if violations.count == 1 {
        return "Validation failed with 1 violation"
      } else {
        return "Validation failed with \(violations.count) violations"
      }
    }
  }
}

/// Represents a single validation violation
public struct ValidationViolation: Codable, Equatable, Sendable {
  /// JSONPath to the invalid field (e.g., "$.tags[1]", "$.author.email")
  public let path: String

  /// Human-readable error message
  public let message: String

  /// Expected type or value (optional)
  public let expected: String?

  /// Actual value found (optional)
  public let actual: String?

  /// Path in the schema that failed (optional)
  public let schemaPath: String?

  public init(
    path: String,
    message: String,
    expected: String? = nil,
    actual: String? = nil,
    schemaPath: String? = nil
  ) {
    self.path = path
    self.message = message
    self.expected = expected
    self.actual = actual
    self.schemaPath = schemaPath
  }
}

extension ValidationViolation: CustomStringConvertible {
  public var description: String {
    var lines = ["Path: \(path)"]
    if let expected = expected {
      lines.append("Expected: \(expected)")
    }
    if let actual = actual {
      lines.append("Actual: \(actual)")
    }
    lines.append("Message: \(message)")
    if let schemaPath = schemaPath {
      lines.append("Schema: \(schemaPath)")
    }
    return lines.joined(separator: "\n")
  }
}
