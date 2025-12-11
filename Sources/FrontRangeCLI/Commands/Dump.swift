//
//  Dump.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

extension FrontRangeCLIEntry {
  struct Dump: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Dump entire front matter in specified format",
      discussion: """
        Outputs the complete front matter from files in various formats: JSON, YAML, raw, or plist.

        Supports multiple files and directory processing with recursive mode.

        SINGLE FILE:
          Single-file dumps output the front matter directly with no wrapper.
          The --multi-format flag is ignored for single files.

        MULTIPLE FILES:
          By default, multiple files use cat-style headers (==> path <==) with empty line separation.
          Use --multi-format to output a structured format instead:

          --multi-format cat (default): Cat-style headers
          --multi-format json: JSON array of {path, frontMatter} objects
          --multi-format yaml: YAML array of {path, frontMatter} objects
          --multi-format plist: PropertyList array of {path, frontMatter} objects

        FORMAT MIXING:
          --format controls individual file content format
          --multi-format controls how multiple files are represented
          Example: --format yaml --multi-format json outputs JSON containing YAML strings

        Examples:
          # Dump single file as JSON
          fr dump post.md

          # Dump with YAML format
          fr dump post.md --format yaml

          # Dump with delimiters
          fr dump post.md --format yaml --include-delimiters

          # Dump multiple files with cat-style headers (default)
          fr dump posts/ -r --format json

          # Dump multiple files as structured JSON
          fr dump file1.md file2.md --multi-format json

          # Mixed format: JSON array with YAML strings
          fr dump posts/ -r --format yaml --multi-format json
        """,
      aliases: ["d"]
    )

    @OptionGroup var options: GlobalOptions

    @Flag(name: .long, help: "Include --- delimiters in YAML/raw output")
    var includeDelimiters: Bool = false

    func run() throws {
      let allPaths = try options.paths
      let isMultipleFiles = allPaths.count > 1

      // Single file: ignore multi-format, output directly
      if !isMultipleFiles {
        let path = allPaths[0]
        printIfDebug("ℹ️ Dumping front matter from '\(path)' in \(options.format.rawValue) format")

        let content = try path.read(.utf8)
        let doc = try FrontMatteredDoc(parsing: content)

        if includeDelimiters && (options.format == .yaml || options.format == .raw) {
          print("---")
        }

        try print(node: .mapping(doc.frontMatter), format: options.format)

        if includeDelimiters && (options.format == .yaml || options.format == .raw) {
          print("---")
        }
        return
      }

      // Multiple files: use multi-format
      if options.multiFormat == .cat {
        // Cat-style output (original behavior)
        for (index, path) in allPaths.enumerated() {
          printIfDebug("ℹ️ Dumping front matter from '\(path)' in \(options.format.rawValue) format")

          print("==> \(path) <==")

          let content = try path.read(.utf8)
          let doc = try FrontMatteredDoc(parsing: content)

          if includeDelimiters && (options.format == .yaml || options.format == .raw) {
            print("---")
          }

          try print(node: .mapping(doc.frontMatter), format: options.format)

          if includeDelimiters && (options.format == .yaml || options.format == .raw) {
            print("---")
          }

          if index < allPaths.count - 1 {
            print()
          }
        }
      } else {
        // Structured output (json, yaml, plist, raw)
        var items: [[String: Any]] = []

        // Check if formats match (treat raw and yaml as equivalent)
        let formatsMatch = formatMatches(format: options.format, multiFormat: options.multiFormat)

        for path in allPaths {
          printIfDebug("ℹ️ Dumping front matter from '\(path)' in \(options.format.rawValue) format")

          let content = try path.read(.utf8)
          let doc = try FrontMatteredDoc(parsing: content)

          let frontMatterValue: Any
          if formatsMatch {
            // Embed structured data when formats match
            frontMatterValue = try structuredFrontMatter(doc.frontMatter, format: options.format)
          } else {
            // Use string representation when formats differ
            frontMatterValue = try renderFrontMatter(doc.frontMatter, format: options.format, includeDelimiters: includeDelimiters)
          }

          items.append([
            "path": path.string,
            "frontMatter": frontMatterValue
          ])
        }

        // Output the structured array in the multi-format
        try printStructuredOutput(items, multiFormat: options.multiFormat)
      }
    }

    /// Renders front matter as a string in the specified format
    private func renderFrontMatter(_ frontMatter: Yams.Node.Mapping, format: OutputFormat, includeDelimiters: Bool) throws -> String {
      var output = ""

      if includeDelimiters && (format == .yaml || format == .raw) {
        output += "---\n"
      }

      let node = Yams.Node.mapping(frontMatter)
      switch format {
        case .json:
          output += try node.toJSON(options: [.prettyPrinted, .sortedKeys])
        case .yaml, .plainString, .raw:
          output += try Yams.serialize(node: node)
        case .plist:
          let constructor = Yams.Constructor.default
          let obj = constructor.any(from: node)
          output += try anyToPlist(obj)
      }

      if includeDelimiters && (format == .yaml || format == .raw) {
        output += "---\n"
      }

      return output
    }

    /// Prints the structured output in the specified multi-format
    private func printStructuredOutput(_ items: [[String: Any]], multiFormat: MultiFormat) throws {
      switch multiFormat {
        case .cat:
          // Should not reach here
          break
        case .json:
          try printAny(items, format: .json)
        case .yaml, .raw:
          try printAny(items, format: .yaml)
        case .plist:
          try printAny(items, format: .plist)
      }
    }

    /// Checks if the format and multi-format match (treating raw and yaml as equivalent)
    private func formatMatches(format: OutputFormat, multiFormat: MultiFormat) -> Bool {
      switch (format, multiFormat) {
        case (.json, .json):
          return true
        case (.yaml, .yaml), (.yaml, .raw), (.raw, .yaml), (.raw, .raw), (.plainString, .yaml), (.plainString, .raw):
          return true
        case (.plist, .plist):
          return true
        default:
          return false
      }
    }

    /// Converts front matter to structured data (dictionary/array) for embedding
    private func structuredFrontMatter(_ frontMatter: Yams.Node.Mapping, format: OutputFormat) throws -> Any {
      let node = Yams.Node.mapping(frontMatter)
      let constructor = Yams.Constructor.default
      return constructor.any(from: node)
    }
  }
}
