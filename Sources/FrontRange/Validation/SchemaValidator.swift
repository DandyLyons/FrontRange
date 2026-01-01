//
//  SchemaValidator.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import JSONSchema
import Yams

/// Validates front matter documents against JSONSchema definitions
public struct SchemaValidator {
  public init() {}

  /// Validate a FrontMatteredDoc against a JSONSchema
  ///
  /// - Parameters:
  ///   - doc: The document to validate
  ///   - schema: The JSONSchema to validate against
  /// - Returns: ValidationResult indicating success or failure with violations
  public func validate(
    _ doc: FrontMatteredDoc,
    against schema: Schema
  ) -> ValidationResult {
    // Convert Yams.Node.Mapping to Swift dictionary for JSONSchema validation
    // Follow the pattern from Search.swift
    let constructor = Yams.Constructor.default
    let frontMatterDict = constructor.any(from: .mapping(doc.frontMatter))

    return validate(frontMatterDict, against: schema, filePath: nil)
  }

  /// Validate front matter mapping directly against a JSONSchema
  ///
  /// - Parameters:
  ///   - mapping: The Yams mapping to validate
  ///   - schema: The JSONSchema to validate against
  ///   - filePath: Optional file path for error reporting
  /// - Returns: ValidationResult indicating success or failure with violations
  public func validate(
    _ mapping: Yams.Node.Mapping,
    against schema: Schema,
    filePath: String? = nil
  ) -> ValidationResult {
    // Convert mapping to Swift dictionary
    let constructor = Yams.Constructor.default
    let dict = constructor.any(from: .mapping(mapping))

    return validate(dict, against: schema, filePath: filePath)
  }

  /// Validate a Swift dictionary against a JSONSchema
  ///
  /// - Parameters:
  ///   - data: The data to validate (typically [String: Any] from Yams conversion)
  ///   - schema: The JSONSchema to validate against
  ///   - filePath: Optional file path for error reporting
  /// - Returns: ValidationResult indicating success or failure with violations
  public func validate(
    _ data: Any,
    against schema: Schema,
    filePath: String? = nil
  ) -> ValidationResult {
    // Use the validate method that returns AnySequence<ValidationError>
    // instead of the one that throws ValidationResult
    let errors: AnySequence<JSONSchema.ValidationError>
    do {
      errors = try schema.validate(data) as AnySequence<JSONSchema.ValidationError>
    } catch {
      // If validation throws, treat it as an error
      let violation = ValidationViolation(
        path: "$",
        message: "Schema validation error: \(error.localizedDescription)"
      )
      return .invalid(violations: [violation], filePath: filePath)
    }

    let violations = errors.map { error -> ValidationViolation in
      convertErrorToViolation(error)
    }

    if violations.isEmpty {
      return .valid(filePath: filePath)
    } else {
      return .invalid(violations: Array(violations), filePath: filePath)
    }
  }

  // MARK: - Private Helpers

  /// Convert JSONSchema validation error to ValidationViolation
  private func convertErrorToViolation(_ error: JSONSchema.ValidationError) -> ValidationViolation {
    // JSONSchema.ValidationError provides error descriptions
    // Extract path and message from the error
    let errorDescription = error.description

    // Try to extract a structured path if available
    // JSONSchema errors often include paths like "property 'tags'" or "item at index 1"
    let path = extractPath(from: errorDescription) ?? "$"
    let message = extractMessage(from: errorDescription)

    return ValidationViolation(
      path: path,
      message: message,
      expected: nil,  // Could extract from error if available
      actual: nil,    // Could extract from error if available
      schemaPath: nil // Could extract from error if available
    )
  }

  /// Extract JSONPath from error description
  private func extractPath(from description: String) -> String? {
    // Common patterns in JSONSchema errors:
    // - "property 'name'" -> "$.name"
    // - "item at index 2" -> "$[2]"
    // - nested paths

    var path = "$"

    // Look for property references
    if let propertyMatch = description.range(of: #"property '([^']+)'"#, options: .regularExpression) {
      let propertyName = description[propertyMatch]
        .replacingOccurrences(of: "property '", with: "")
        .replacingOccurrences(of: "'", with: "")
      path += ".\(propertyName)"
    }

    // Look for array index references
    if let indexMatch = description.range(of: #"index (\d+)"#, options: .regularExpression) {
      let indexStr = description[indexMatch]
        .replacingOccurrences(of: "index ", with: "")
      path += "[\(indexStr)]"
    }

    return path == "$" ? nil : path
  }

  /// Extract human-readable message from error description
  private func extractMessage(from description: String) -> String {
    // Remove technical prefixes and clean up the message
    var message = description

    // Common prefixes to remove
    let prefixes = [
      "Validation failed: ",
      "Invalid: ",
      "Error: "
    ]

    for prefix in prefixes {
      if message.hasPrefix(prefix) {
        message = String(message.dropFirst(prefix.count))
      }
    }

    return message.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
