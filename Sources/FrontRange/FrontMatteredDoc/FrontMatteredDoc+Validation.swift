//
//  FrontMatteredDoc+Validation.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import JSONSchema

// MARK: - Validation

extension FrontMatteredDoc {
  /// Validate this document against a JSONSchema
  ///
  /// - Parameter schema: The schema to validate against
  /// - Returns: ValidationResult indicating success or failure
  ///
  /// Example:
  /// ```swift
  /// let doc = try FrontMatteredDoc(parsing: content)
  /// let schema = try Schema(jsonObject)
  /// let result = doc.validate(against: schema)
  /// if !result.isValid {
  ///   print("Validation failed:")
  ///   for violation in result.violations {
  ///     print("  - \(violation)")
  ///   }
  /// }
  /// ```
  public func validate(against schema: Schema) -> ValidationResult {
    let validator = SchemaValidator()
    return validator.validate(self, against: schema)
  }

  /// Validate this document with automatic schema resolution
  ///
  /// This method resolves the schema based on priority:
  /// 1. Explicit schemaPath parameter (if provided)
  /// 2. Embedded $schema key in frontmatter
  /// 3. Project config (future: Phase 3)
  ///
  /// - Parameters:
  ///   - schemaPath: Optional explicit schema path
  ///   - resolver: Schema resolver to use (creates new one if nil)
  /// - Returns: ValidationResult indicating success or failure
  /// - Throws: ValidationError if schema resolution or loading fails
  ///
  /// Example:
  /// ```swift
  /// let doc = try FrontMatteredDoc(parsing: content)
  /// let resolver = SchemaResolver()
  ///
  /// // Use explicit schema
  /// let result1 = try doc.validate(schemaPath: "schemas/post.json", resolver: resolver)
  ///
  /// // Use embedded $schema key
  /// let result2 = try doc.validate(resolver: resolver)
  /// ```
  public func validate(
    schemaPath: String? = nil,
    resolver: SchemaResolver? = nil
  ) throws -> ValidationResult {
    let schemaResolver = resolver ?? SchemaResolver()

    // Get embedded $schema value
    let embeddedSchema = self.getValue(forKey: "$schema")

    // Resolve schema
    guard let schema = try schemaResolver.resolveSchema(
      explicit: schemaPath,
      embedded: embeddedSchema,
      filePath: nil
    ) else {
      throw ValidationError.schemaNotFound("No schema found. Provide schemaPath or add $schema key to frontmatter.")
    }

    return validate(against: schema)
  }
}
