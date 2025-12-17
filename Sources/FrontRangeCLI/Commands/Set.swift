//
//  Set.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct Set: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Set a value in frontmatter",
      discussion: """
        Set a key-value pair in the front matter of one or more files.

        VALIDATION (OPT-IN):
          Use --validate to validate the document after setting the value.
          If validation fails, the file will NOT be modified.

        EXAMPLES:
          # Set a value
          fr set --key draft --value false post.md

          # Set with validation
          fr set --key draft --value false post.md --validate --validate-schema schemas/post.json
        """
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .shortAndLong,
      help: "The key to set")
    var key: String

    @Option(help: "The value to set")
    var value: String

    @Flag(name: .long, help: "Validate against schema after setting (OPT-IN)")
    var validate: Bool = false

    @Option(name: .long, help: "Schema to validate against")
    var validateSchema: String?

    func run() throws {
      // Initialize resolver if validation is enabled
      let resolver = validate ? SchemaResolver() : nil

      for path in try options.paths {
        printIfDebug("ℹ️Setting key '\(key)' to '\(value)' in file '\(path)'")

        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)

        // Apply mutation
        doc.setValue(value, forKey: key)

        // Validate if requested (OPT-IN)
        if validate {
          printIfDebug("🔍 Validating after mutation...")

          guard let schemaResolver = resolver else {
            throw ValidationError.schemaNotFound("Resolver not initialized")
          }

          // Resolve schema
          let embeddedSchema = doc.getValue(forKey: "$schema")
          guard let schema = try schemaResolver.resolveSchema(
            explicit: validateSchema,
            embedded: embeddedSchema,
            filePath: path.absolute().string
          ) else {
            throw ValidationError.schemaNotFound(
              "No schema found. Provide --validate-schema or add $schema key to frontmatter."
            )
          }

          // Validate
          let validator = SchemaValidator()
          let result = validator.validate(doc, against: schema)

          if !result.isValid {
            // Print violations to stderr
            printToStderr("✗ Validation failed for \(path.string):\n")
            for (index, violation) in result.violations.enumerated() {
              printToStderr(formatViolation(violation, index: index))
              printToStderr("\n")
            }

            // Block the save - throw error
            throw ValidationError.validationFailed(violations: result.violations)
          }

          printIfDebug("✅ Validation passed")
        }

        // Save if validation passed (or not requested)
        let updatedContent = try doc.render()
        try path.write(updatedContent)
      }
    }
  }
}
