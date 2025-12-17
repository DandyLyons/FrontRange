//
//  ValidateTool.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import FrontRange
import MCP

func runValidateTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }

  let schemaPath = params.arguments?["schema"]?.stringValue
  let formatString = params.arguments?["format"]?.stringValue ?? "detailed"

  do {
    // Read and parse document
    let content = try String(contentsOfFile: path, encoding: .utf8)
    let doc = try FrontMatteredDoc(parsing: content)

    // Initialize schema resolver
    let resolver = SchemaResolver()

    // Resolve schema
    let embeddedSchema = doc.getValue(forKey: "$schema")
    guard let schema = try resolver.resolveSchema(
      explicit: schemaPath,
      embedded: embeddedSchema,
      filePath: path
    ) else {
      return CallTool.Result(
        content: [.text("No schema found. Provide 'schema' parameter or add $schema key to frontmatter.")],
        isError: true
      )
    }

    // Validate
    let validator = SchemaValidator()
    var result = validator.validate(doc, against: schema)

    // Add file path to result
    result = ValidationResult(
      isValid: result.isValid,
      violations: result.violations,
      filePath: path
    )

    // Format output based on requested format
    let output = formatValidationOutput(result, format: formatString)

    return CallTool.Result(
      content: [.text(output)],
      isError: !result.isValid
    )

  } catch let error as ValidationError {
    return CallTool.Result(
      content: [.text("Validation error: \(error.description)")],
      isError: true
    )
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}

// MARK: - Formatting Helpers

private func formatValidationOutput(_ result: ValidationResult, format: String) -> String {
  switch format.lowercased() {
  case "json":
    return formatAsJSON(result)
  case "summary":
    return formatAsSummary(result)
  default: // "detailed"
    return formatAsDetailed(result)
  }
}

private func formatAsDetailed(_ result: ValidationResult) -> String {
  if result.isValid {
    if let path = result.filePath {
      return "✓ Valid: \(path)"
    } else {
      return "✓ Valid"
    }
  } else {
    var output = if let path = result.filePath {
      "✗ Invalid: \(path) (\(result.violations.count) violation\(result.violations.count == 1 ? "" : "s"))"
    } else {
      "✗ Invalid (\(result.violations.count) violation\(result.violations.count == 1 ? "" : "s"))"
    }

    for (index, violation) in result.violations.enumerated() {
      output += "\n\nError \(index + 1): \(violation.path)"
      if let expected = violation.expected {
        output += "\n  Expected: \(expected)"
      }
      if let actual = violation.actual {
        output += "\n  Actual: \(actual)"
      }
      output += "\n  Message: \(violation.message)"
    }

    return output
  }
}

private func formatAsSummary(_ result: ValidationResult) -> String {
  if result.isValid {
    return "Valid: \(result.filePath ?? "document")"
  } else {
    return "Invalid: \(result.filePath ?? "document") - \(result.violations.count) violation(s)"
  }
}

private func formatAsJSON(_ result: ValidationResult) -> String {
  let jsonObject: [String: Any] = [
    "valid": result.isValid,
    "file": result.filePath ?? "",
    "violations": result.violations.map { violation in
      [
        "path": violation.path,
        "message": violation.message,
        "expected": violation.expected as Any,
        "actual": violation.actual as Any,
        "schemaPath": violation.schemaPath as Any
      ]
    }
  ]

  guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
        let jsonString = String(data: jsonData, encoding: .utf8) else {
    return "{\"error\": \"Failed to serialize JSON\"}"
  }

  return jsonString
}
