//
//  ValidationResult.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation

/// Result of validating a document against a schema
public struct ValidationResult: Codable, Equatable {
  /// Whether the document is valid according to the schema
  public let isValid: Bool

  /// List of validation violations (empty if valid)
  public let violations: [ValidationViolation]

  /// Optional file path that was validated
  public let filePath: String?

  public init(
    isValid: Bool,
    violations: [ValidationViolation] = [],
    filePath: String? = nil
  ) {
    self.isValid = isValid
    self.violations = violations
    self.filePath = filePath
  }

  /// Create a successful validation result
  public static func valid(filePath: String? = nil) -> ValidationResult {
    ValidationResult(isValid: true, violations: [], filePath: filePath)
  }

  /// Create a failed validation result
  public static func invalid(
    violations: [ValidationViolation],
    filePath: String? = nil
  ) -> ValidationResult {
    ValidationResult(isValid: false, violations: violations, filePath: filePath)
  }
}

extension ValidationResult: CustomStringConvertible {
  public var description: String {
    if isValid {
      if let path = filePath {
        return "✓ Valid: \(path)"
      } else {
        return "✓ Valid"
      }
    } else {
      let violationCount = violations.count
      let header = if let path = filePath {
        "✗ Invalid: \(path) (\(violationCount) violation\(violationCount == 1 ? "" : "s"))"
      } else {
        "✗ Invalid (\(violationCount) violation\(violationCount == 1 ? "" : "s"))"
      }

      let violationDetails = violations.enumerated().map { index, violation in
        "\n  \(index + 1). \(violation.path): \(violation.message)"
      }.joined()

      return header + violationDetails
    }
  }
}

/// Summary statistics for batch validation
public struct ValidationSummary: Codable, Equatable {
  /// Total number of files processed
  public let totalFiles: Int

  /// Number of valid files
  public let validFiles: Int

  /// Number of invalid files
  public let invalidFiles: Int

  /// Number of files that had errors (parse errors, schema errors)
  public let errorFiles: Int

  /// Total number of validation violations across all files
  public let totalViolations: Int

  public init(
    totalFiles: Int,
    validFiles: Int,
    invalidFiles: Int,
    errorFiles: Int,
    totalViolations: Int
  ) {
    self.totalFiles = totalFiles
    self.validFiles = validFiles
    self.invalidFiles = invalidFiles
    self.errorFiles = errorFiles
    self.totalViolations = totalViolations
  }

  /// Percentage of valid files (0-100)
  public var validPercentage: Double {
    guard totalFiles > 0 else { return 0 }
    return Double(validFiles) / Double(totalFiles) * 100
  }

  /// Percentage of invalid files (0-100)
  public var invalidPercentage: Double {
    guard totalFiles > 0 else { return 0 }
    return Double(invalidFiles) / Double(totalFiles) * 100
  }
}

extension ValidationSummary: CustomStringConvertible {
  public var description: String {
    """
    Summary:
      Total: \(totalFiles)
      Valid: \(validFiles) (\(String(format: "%.1f", validPercentage))%)
      Invalid: \(invalidFiles) (\(String(format: "%.1f", invalidPercentage))%)
      Errors: \(errorFiles)
    """
  }
}
