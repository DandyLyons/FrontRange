//
//  Search.swift
//  FrontRange
//
//  Created by Daniel Lyons on 12/6/25.
//

import ArgumentParser
import Foundation
import FrontRange
import JMESPath
import PathKit
import Yams

extension FrontRangeCLIEntry {
  struct Search: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Search for files matching a JMESPath query",
      discussion: """
        Search for files whose front matter matches a JMESPath expression.

        The query is evaluated against each file's YAML front matter.
        Files where the expression evaluates to true (or truthy) are included.

        Directories are searched recursively.

        EXAMPLES:
          # Find all draft files (use single quotes around query for shell safety)
          fr search 'draft == `true`' .

          # Find files with specific tag (both string syntaxes work)
          fr search "contains(tags, 'swift')" ./posts
          fr search 'contains(tags, `"swift"`)' ./posts

          # Complex query with multiple conditions
          fr search 'draft == `false` && author == `"John"`' .

        JMESPATH SYNTAX:
          - Comparisons: ==, !=, <, <=, >, >=
          - Literals:
            - Booleans (use backticks): `true`, `false`
            - Numbers (use backticks): `42`, `3.14`
            - Strings (two syntaxes work):
              • Simple: 'text' or "text"
              • Literal: `"text"` or `'text'` (with backticks)
            - Null: `null`
          - Functions: contains(), length(), starts_with(), etc.
          - Logical: &&, ||, !
          - See https://jmespath.org for full syntax

        SHELL ESCAPING TIPS:
          Backticks (`) are special in some shells (command substitution).
          Use appropriate shell quoting to avoid issues:

          ✓ Single quotes (safest):    fr search 'draft == `true`' .
          ✓ Double quotes (careful):   fr search "contains(tags, 'swift')" .
            Some shells (like Zsh and Bash) will misinterpret backticks inside double quotes.
          ✗ Wrong - missing backticks: fr search "draft == true" .
            (without backticks, JMESPath will treat "true" as a field name, not boolean!)

        PIPING TO OTHER COMMANDS:
          The search command outputs file paths (one per line), making it perfect
          for piping into other commands:

          # Bulk update: mark all drafts as published
          fr search 'draft == `true`' ./posts | xargs fr set --key draft --value false

          # Chain operations: publish posts and add date
          fr search 'ready == `true`' . | while read -r file; do
            fr set "$file" --key published --value true
            fr set "$file" --key date --value "$(date +%Y-%m-%d)"
          done

          # Remove a key from matching files
          fr search 'deprecated == `true`' . | xargs fr remove --key temporary
        """
    )

    @Argument(help: "JMESPath expression to filter files")
    var query: String

    @Argument(help: "Path(s) to the file(s)/directory(ies) to search")
    var paths: [Path]

    @Option(name: [.short, .long], help: "Output format")
    var format: OutputFormat = .plainString

    @Option(
      name: [.short, .long],
      help: "File extensions to process (comma-separated, no spaces)"
    )
    var extensions: String = "md,markdown,yml,yaml"

    func run() throws {
      printIfDebug("🔍 Searching files with query: '\(query)'")

      // Compile the JMESPath expression once
      let expression: JMESExpression
      do {
        expression = try JMESExpression.compile(query)
      } catch {
        // Extract the actual error message from JMESPathError
        let errorDescription = String(describing: error)
        let errorMessage: String

        // Try to extract the message from patterns like: compileTime("message") or runtime("message")
        let patterns = [
          #"compileTime\("([^"]+)"\)"#,
          #"runtime\("([^"]+)"\)"#
        ]

        var extractedMessage: String? = nil
        for pattern in patterns {
          if let match = errorDescription.range(of: pattern, options: .regularExpression),
             let captureRange = errorDescription.range(of: #""([^"]+)""#, options: .regularExpression, range: match) {
            extractedMessage = String(errorDescription[captureRange].dropFirst().dropLast())
            break
          }
        }

        errorMessage = extractedMessage ?? error.localizedDescription

        throw ValidationError("""
          Invalid JMESPath expression: "\(query)"
          \(errorMessage)

          See https://jmespath.org for syntax reference
          """)
      }

      var matchingFiles: [String] = []
      let processedPaths = try expandPaths()

      for path in processedPaths {
        printIfDebug("ℹ️ Checking file: \(path.string)")

        // Parse the file
        let content: String
        let doc: FrontMatteredDoc
        do {
          content = try path.read(.utf8)
          doc = try FrontMatteredDoc(parsing: content)
        } catch {
          printIfDebug("⚠️ Failed to parse \(path.string): \(error.localizedDescription) - skipping")
          continue
        }

        // Convert Yams.Node.Mapping to Swift dictionary for JMESPath
        let constructor = Yams.Constructor.default
        let frontMatterDict: Any = constructor.any(from: .mapping(doc.frontMatter))

        // Evaluate the JMESPath expression against the front matter
        do {
          let result = try expression.search(object: frontMatterDict)

          // Check if result is truthy
          if isTruthy(result) {
            matchingFiles.append(path.absolute().string)
            printIfDebug("✅ Match found in: \(path.string)")
          } else {
            printIfDebug("❌ No match in: \(path.string)")
          }
        } catch {
          printIfDebug("⚠️ Query evaluation failed for \(path.string): \(error.localizedDescription) - skipping")
          continue
        }
      }

      // Output results based on format
      if matchingFiles.isEmpty {
        // Print helpful message to stderr (doesn't interfere with piping stdout)
        fputs("No files matched the query: \"\(query)\"\n", stderr)
        fputs("Searched \(processedPaths.count) file(s)\n", stderr)
      } else {
        switch format {
        case .json:
          try printAny(matchingFiles, format: .json)
        case .yaml:
          try printAny(matchingFiles, format: .yaml)
        case .plainString:
          // Plain text: one file path per line
          print(matchingFiles.joined(separator: "\n"))
        }
      }
    }

    /// Expand paths with recursive directory traversal and extension filtering
    /// Search command is always recursive
    private func expandPaths() throws -> [Path] {
      var allPaths: [Path] = []

      for path in self.paths {
        if path.isDirectory {
          // Always search recursively
          let recursiveChildren = try path.recursiveChildren()
          allPaths.append(contentsOf: recursiveChildren)
        } else {
          allPaths.append(path)
        }
      }

      // Filter by extensions
      let exts: [String] = self.extensions
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        .filter { !$0.isEmpty }

      if !exts.isEmpty {
        allPaths = allPaths.filter { path in
          guard let fileExt = path.extension?.lowercased() else { return false }
          return exts.contains(fileExt)
        }
      }

      return allPaths
    }

    /// Determines if a value is "truthy" for the purposes of filtering
    /// - JMESPath returns various types; we treat non-false, non-nil, non-empty as truthy
    private func isTruthy(_ value: Any?) -> Bool {
      guard let value = value else {
        return false
      }

      // Handle various types
      if let bool = value as? Bool {
        return bool
      }
      if let string = value as? String {
        return !string.isEmpty
      }
      if let array = value as? [Any] {
        return !array.isEmpty
      }
      if let dict = value as? [String: Any] {
        return !dict.isEmpty
      }

      // For other types (numbers, objects), consider them truthy if non-nil
      return true
    }
  }
}
