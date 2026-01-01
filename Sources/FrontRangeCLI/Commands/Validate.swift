//
//  Validate.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct Validate: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Validate front matter against JSONSchema",
      discussion: """
        Validate YAML front matter in files against JSONSchema definitions.

        IMPORTANT: Validation is OPT-IN ONLY. This command must be explicitly run.
        Having a schema file or $schema key does NOT automatically enable validation.

        SCHEMA SOURCES (in priority order):
          1. --schema: Explicit schema file path or URL
          2. $schema key in frontmatter
          3. .frontrange.yml project configuration (future)

        EXAMPLES:
          # Validate with explicit schema
          fr validate posts/*.md --schema schemas/blog-post.json

          # Validate using embedded $schema key
          fr validate post.md

          # Validate all files recursively
          fr validate . --recursive

          # Get detailed output in JSON
          fr validate posts/ --format json --schema schemas/post.json

          # Continue on errors, validate all files
          fr validate . -r --continue-on-error --schema schemas/default.json

          # Summary output only
          fr validate posts/ --format summary --schema schemas/post.json
        """,
      aliases: ["val"]
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .long, help: "Path to JSONSchema file")
    var schema: String?

    @Flag(name: .long, help: "Continue validating all files even after errors")
    var continueOnError: Bool = false

    @Flag(name: .long, help: "Suppress detailed error output")
    var quiet: Bool = false

    @Option(name: [.short, .long], help: "Output format: detailed (default), summary, json, yaml")
    var outputFormat: ValidateOutputFormat = .detailed

    func run() throws {
      printIfDebug("🔍 Starting validation with schema: \(schema ?? "(auto-resolve)")")

      // Initialize schema resolver
      let resolver = SchemaResolver()

      // Get all file paths
      let paths = try options.paths

      printIfDebug("📁 Found \(paths.count) file(s) to validate")

      // Process files in batches
      let batchSize = 500
      let totalBatches = (paths.count + batchSize - 1) / batchSize

      var allResults: [ValidationResult] = []
      var errorFiles: [(String, Error)] = []

      for (batchIndex, batch) in paths.chunked(into: batchSize).enumerated() {
        let batchNumber = batchIndex + 1

        if paths.count > batchSize {
          printToStderr("Processing batch \(batchNumber)/\(totalBatches)...\n")
        }

        let (results, errors) = processBatch(batch, resolver: resolver)
        allResults.append(contentsOf: results)
        errorFiles.append(contentsOf: errors)

        if !continueOnError && !errors.isEmpty {
          break
        }
      }

      // Output results based on format
      try outputResults(allResults, errors: errorFiles)

      // Exit with appropriate code
      let hasInvalid = allResults.contains { !$0.isValid }
      let hasErrors = !errorFiles.isEmpty

      if hasErrors {
        throw ExitCode(2) // Errors during validation
      } else if hasInvalid {
        throw ExitCode(1) // Validation failures
      }
      // Exit code 0 - all valid
    }

    // MARK: - Batch Processing

    private func processBatch(
      _ paths: [Path],
      resolver: SchemaResolver
    ) -> (results: [ValidationResult], errors: [(String, Error)]) {
      var results: [ValidationResult] = []
      var errors: [(String, Error)] = []

      for path in paths {
        printIfDebug("ℹ️ Validating: \(path.string)")

        do {
          // Read and parse document
          let content = try path.read(.utf8)
          let doc = try FrontMatteredDoc(parsing: content)

          // Resolve schema
          let embeddedSchema = doc.getValue(forKey: "$schema")
          guard let resolvedSchema = try resolver.resolveSchema(
            explicit: schema,
            embedded: embeddedSchema,
            filePath: path.absolute().string
          ) else {
            let error = ValidationError.schemaNotFound(
              "No schema found. Provide --schema flag or add $schema key to frontmatter."
            )
            errors.append((path.absolute().string, error))
            printIfDebug("⚠️ No schema found for: \(path.string)")
            continue
          }

          // Validate
          let validator = SchemaValidator()
          var result = validator.validate(doc, against: resolvedSchema)

          // Add file path to result
          result = ValidationResult(
            isValid: result.isValid,
            violations: result.violations,
            filePath: path.absolute().string
          )

          results.append(result)

          if result.isValid {
            printIfDebug("✅ Valid: \(path.string)")
          } else {
            printIfDebug("❌ Invalid: \(path.string) (\(result.violations.count) violations)")
          }

        } catch {
          errors.append((path.absolute().string, error))
          printIfDebug("⚠️ Error processing \(path.string): \(error)")
        }
      }

      return (results, errors)
    }

    // MARK: - Output Formatting

    private func outputResults(
      _ results: [ValidationResult],
      errors: [(String, Error)]
    ) throws {
      let validResults = results.filter { $0.isValid }
      let invalidResults = results.filter { !$0.isValid }

      switch outputFormat {
      case .detailed:
        outputDetailed(results: results, errors: errors)

      case .summary:
        outputSummary(valid: validResults, invalid: invalidResults, errors: errors)

      case .json:
        try outputJSON(results: results, errors: errors)

      case .yaml:
        try outputYAML(results: results, errors: errors)
      }
    }

    private func outputDetailed(results: [ValidationResult], errors: [(String, Error)]) {
      // Print individual results
      for result in results {
        if !quiet || !result.isValid {
          print(formatDetailedResult(result))
          print("") // Blank line between results
        }
      }

      // Print errors
      if !errors.isEmpty {
        print("Errors encountered:")
        for (path, error) in errors {
          print("  ✗ \(path)")
          print("    \(error.localizedDescription)")
        }
        print("")
      }

      // Print summary
      let summary = createSummary(results: results, errors: errors)
      print(formatSummary(summary))
    }

    private func outputSummary(
      valid: [ValidationResult],
      invalid: [ValidationResult],
      errors: [(String, Error)]
    ) {
      let validPaths = valid.compactMap { $0.filePath }
      let invalidPaths = invalid.map { ($0.filePath ?? "", $0.violations.count) }

      print(formatFileSummary(valid: validPaths, invalid: invalidPaths))

      let summary = createSummary(results: valid + invalid, errors: errors)
      print(formatSummary(summary))
    }

    private func outputJSON(results: [ValidationResult], errors: [(String, Error)]) throws {
      let summary = createSummary(results: results, errors: errors)

      let output: [String: Any] = [
        "total": summary.totalFiles,
        "valid": summary.validFiles,
        "invalid": summary.invalidFiles,
        "errorCount": summary.errorFiles,
        "results": results.map { result in
          [
            "file": result.filePath ?? "",
            "valid": result.isValid,
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
        },
        "errors": errors.map { (path, error) in
          [
            "file": path,
            "error": error.localizedDescription
          ]
        }
      ]

      let jsonData = try JSONSerialization.data(withJSONObject: output, options: .prettyPrinted)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
      }
    }

    private func outputYAML(results: [ValidationResult], errors: [(String, Error)]) throws {
      // For YAML output, we'll use a similar structure to JSON but format as YAML
      let summary = createSummary(results: results, errors: errors)

      print("total: \(summary.totalFiles)")
      print("valid: \(summary.validFiles)")
      print("invalid: \(summary.invalidFiles)")
      print("errors: \(summary.errorFiles)")
      print("results:")

      for result in results {
        print("  - file: \"\(result.filePath ?? "")\"")
        print("    valid: \(result.isValid)")

        if !result.violations.isEmpty {
          print("    violations:")
          for violation in result.violations {
            print("      - path: \"\(violation.path)\"")
            print("        message: \"\(violation.message)\"")
            if let expected = violation.expected {
              print("        expected: \"\(expected)\"")
            }
            if let actual = violation.actual {
              print("        actual: \"\(actual)\"")
            }
          }
        }
      }

      if !errors.isEmpty {
        print("errors:")
        for (path, error) in errors {
          print("  - file: \"\(path)\"")
          print("    error: \"\(error.localizedDescription)\"")
        }
      }
    }

    // MARK: - Helper Methods

    private func createSummary(
      results: [ValidationResult],
      errors: [(String, Error)]
    ) -> ValidationSummary {
      let validCount = results.filter { $0.isValid }.count
      let invalidCount = results.filter { !$0.isValid }.count
      let totalViolations = results.reduce(0) { $0 + $1.violations.count }

      return ValidationSummary(
        totalFiles: results.count + errors.count,
        validFiles: validCount,
        invalidFiles: invalidCount,
        errorFiles: errors.count,
        totalViolations: totalViolations
      )
    }
  }
}

// MARK: - Array Extensions

private extension Array {
  func chunked(into size: Int) -> [[Element]] {
    guard size > 0 else { return [self] }
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}
