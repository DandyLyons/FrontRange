//
//  ValidationFormatters.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import FrontRange

/// Format a validation violation for detailed output
func formatViolation(_ violation: ValidationViolation, index: Int) -> String {
  var lines = ["  Error \(index + 1): \(violation.path)"]

  if let expected = violation.expected {
    lines.append("    Expected: \(expected)")
  }
  if let actual = violation.actual {
    lines.append("    Actual: \(actual)")
  }
  lines.append("    Message: \(violation.message)")

  if let schemaPath = violation.schemaPath {
    lines.append("    Schema: \(schemaPath)")
  }

  return lines.joined(separator: "\n")
}

/// Format a validation result for detailed output
func formatDetailedResult(_ result: ValidationResult) -> String {
  if let path = result.filePath {
    if result.isValid {
      return "Validating: \(path)\n✓ Valid"
    } else {
      var output = "Validating: \(path)\n✗ Validation failed (\(result.violations.count) error\(result.violations.count == 1 ? "" : "s"))\n"

      for (index, violation) in result.violations.enumerated() {
        output += "\n" + formatViolation(violation, index: index)
      }

      return output
    }
  } else {
    if result.isValid {
      return "✓ Valid"
    } else {
      var output = "✗ Validation failed (\(result.violations.count) error\(result.violations.count == 1 ? "" : "s"))\n"

      for (index, violation) in result.violations.enumerated() {
        output += "\n" + formatViolation(violation, index: index)
      }

      return output
    }
  }
}

/// Format validation summary statistics
func formatSummary(_ summary: ValidationSummary) -> String {
  let validPct = String(format: "%.1f", summary.validPercentage)
  let invalidPct = String(format: "%.1f", summary.invalidPercentage)

  return """

  Summary:
    Total: \(summary.totalFiles)
    Valid: \(summary.validFiles) (\(validPct)%)
    Invalid: \(summary.invalidFiles) (\(invalidPct)%)
    Errors: \(summary.errorFiles)
  """
}

/// Format a list of files for summary output
func formatFileSummary(valid: [String], invalid: [(String, Int)]) -> String {
  var output = ""

  if !valid.isEmpty {
    output += "Valid files (\(valid.count)):\n"
    for path in valid.prefix(10) {
      output += "  ✓ \(path)\n"
    }
    if valid.count > 10 {
      output += "  ... and \(valid.count - 10) more\n"
    }
  }

  if !invalid.isEmpty {
    if !output.isEmpty { output += "\n" }
    output += "Invalid files (\(invalid.count)):\n"
    for (path, count) in invalid.prefix(10) {
      output += "  ✗ \(path) (\(count) violation\(count == 1 ? "" : "s"))\n"
    }
    if invalid.count > 10 {
      output += "  ... and \(invalid.count - 10) more\n"
    }
  }

  return output
}
