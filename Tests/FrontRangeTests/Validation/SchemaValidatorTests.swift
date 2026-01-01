//
//  SchemaValidatorTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import Testing
@testable import FrontRange
import JSONSchema

@Suite("SchemaValidator Tests")
struct SchemaValidatorTests {

  @Test("Valid document passes validation")
  func validDocumentPassesValidation() throws {
    // Create a simple schema
    let schemaDict: [String: Any] = [
      "type": "object",
      "properties": [
        "title": ["type": "string"],
        "draft": ["type": "boolean"]
      ],
      "required": ["title"]
    ]
    let schema = Schema(schemaDict)

    // Create a valid document
    let content = """
    ---
    title: My Post
    draft: true
    ---
    Body content here
    """

    let doc = try FrontMatteredDoc(parsing: content)

    // Validate
    let validator = SchemaValidator()
    let result = validator.validate(doc, against: schema)

    #expect(result.isValid)
    #expect(result.violations.isEmpty)
  }

  @Test("Invalid document fails validation with violations")
  func invalidDocumentFailsValidation() throws {
    // Create a schema with required field
    let schemaDict: [String: Any] = [
      "type": "object",
      "properties": [
        "title": ["type": "string"],
        "count": ["type": "number"]
      ],
      "required": ["title", "count"]
    ]
    let schema = Schema(schemaDict)

    // Create document missing required field
    let content = """
    ---
    title: My Post
    ---
    Body content
    """

    let doc = try FrontMatteredDoc(parsing: content)

    // Validate
    let validator = SchemaValidator()
    let result = validator.validate(doc, against: schema)

    #expect(!result.isValid)
    #expect(!result.violations.isEmpty)
    #expect(result.violations.count > 0)
  }

  @Test("Type mismatch is detected")
  func typeMismatchIsDetected() throws {
    // Schema expects boolean
    let schemaDict: [String: Any] = [
      "type": "object",
      "properties": [
        "draft": ["type": "boolean"]
      ]
    ]
    let schema = Schema(schemaDict)

    // Document has string instead of boolean
    let content = """
    ---
    draft: "yes"
    ---
    Body
    """

    let doc = try FrontMatteredDoc(parsing: content)

    // Validate
    let validator = SchemaValidator()
    let result = validator.validate(doc, against: schema)

    #expect(!result.isValid)
    #expect(result.violations.count > 0)
  }

  @Test("Minimal frontmatter validates against minimal schema")
  func minimalFrontmatterValidatesAgainstMinimalSchema() throws {
    // Minimal schema - just require it to be an object
    let schemaDict: [String: Any] = [
      "type": "object"
    ]
    let schema = Schema(schemaDict)

    // Document with minimal frontmatter (at least one key to form valid YAML)
    let content = """
    ---
    type: post
    ---
    Body content
    """

    let doc = try FrontMatteredDoc(parsing: content)

    // Validate
    let validator = SchemaValidator()
    let result = validator.validate(doc, against: schema)

    #expect(result.isValid)
  }
}
