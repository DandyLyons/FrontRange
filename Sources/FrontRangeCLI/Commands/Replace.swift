//
//  Replace.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit
import Yams

extension FrontRangeCLIEntry {
  struct Replace: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Replace entire front matter with new data",
      discussion: """
        Replace the complete front matter in files with new structured data.

        This is a DESTRUCTIVE operation - the entire front matter will be replaced.
        You will be prompted for confirmation before changes are made.

        INPUT METHODS:
          Provide data either inline or from a file (but not both):

          --data: Inline data string
            fr replace post.md --data '{"title": "New", "draft": false}' --format json

          --from-file: Read from file
            fr replace post.md --from-file new-frontmatter.json --format json

          TIP: When passing inline data that starts with -, use --data= syntax:
            fr replace post.md --data='- item1' --format yaml
            This prevents the argument parser from treating - as a flag.

        SUPPORTED FORMATS:
          - json: JavaScript Object Notation
          - yaml: YAML Ain't Markup Language
          - plist: Apple PropertyList XML

        VALIDATION:
          Front matter must be a dictionary/mapping. Arrays and scalars will be rejected.

        CONFIRMATION:
          You will be prompted to confirm before replacing. Use this carefully!

        Examples:
          # Replace with inline JSON
          fr replace post.md --data '{"title": "New Title", "draft": false}' --format json

          # Replace from YAML file
          fr replace post.md --from-file metadata.yaml --format yaml

          # Replace from plist
          fr replace post.md --from-file metadata.plist --format plist

          # Process multiple files (prompted once per file)
          fr replace post1.md post2.md --data '{"status": "published"}' --format json
        """,
      aliases: ["r"]
    )

    @Option(name: .long, help: "Inline data to use as new front matter")
    var data: String?

    @Option(name: .long, help: "Path to file containing new front matter")
    var fromFile: String?

    @Option(name: [.short, .long], help: "Data format (json, yaml, plist)")
    var format: DataFormat = .json

    @Flag(name: .long, help: "Validate against schema after replacement (OPT-IN)")
    var validate: Bool = false

    @Option(name: .long, help: "Schema to validate against")
    var validateSchema: String?

    @Argument(help: "Path(s) to the file(s) to process")
    var paths: [Path]

    func run() throws {
      // Validate input options
      guard data != nil || fromFile != nil else {
        throw ValidationError("Must specify either --data or --from-file")
      }

      guard !(data != nil && fromFile != nil) else {
        throw ValidationError("Cannot use both --data and --from-file")
      }

      // Get the data string
      let dataString: String
      if let inlineData = data {
        dataString = inlineData
      } else if let filePath = fromFile {
        printIfDebug("ℹ️ Reading replacement data from '\(filePath)'")
        dataString = try Path(filePath).read(.utf8)
      } else {
        throw ValidationError("Must specify either --data or --from-file")
      }

      // Parse to mapping
      printIfDebug("ℹ️ Parsing \(format.rawValue) data to front matter mapping")
      let newFrontMatter: Yams.Node.Mapping
      do {
        newFrontMatter = try parseToMapping(dataString, format: format)
      } catch let error as DataParsingError {
        throw ValidationError(error.description)
      }

      // Initialize resolver if validation is enabled
      let resolver = validate ? SchemaResolver() : nil

      // Process each file
      for path in paths {
        try replaceInFile(path: path, newFrontMatter: newFrontMatter, resolver: resolver)
      }
    }

    private func replaceInFile(
      path: Path,
      newFrontMatter: Yams.Node.Mapping,
      resolver: SchemaResolver?
    ) throws {
      printIfDebug("ℹ️ Processing '\(path)'")

      // Read and parse document
      let content = try path.read(.utf8)
      var doc = try FrontMatteredDoc(parsing: content)

      // Replace front matter (direct assignment)
      doc.frontMatter = newFrontMatter

      // Validate if requested (OPT-IN) - BEFORE confirmation
      if validate, let schemaResolver = resolver {
        printIfDebug("🔍 Validating after replacement...")

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

          // Block the save - throw error (skip confirmation)
          throw ValidationError.validationFailed(violations: result.violations)
        }

        printIfDebug("✅ Validation passed")
      }

      // Prompt for confirmation (interactive) - AFTER validation passes
      print("⚠️  This will REPLACE the entire front matter in '\(path)'. Continue? (y/n): ", terminator: "")
      // Flush stdout to ensure prompt appears before readLine()
      FileHandle.standardOutput.synchronizeFile()

      guard let response = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
        print("Cancelled (no input).")
        return
      }

      guard response == "y" || response == "yes" else {
        print("Cancelled.")
        return
      }

      // Render and write back
      let updatedContent = try doc.render()
      try path.write(updatedContent)

      print("✓ Replaced front matter in '\(path)'")
    }
  }
}
