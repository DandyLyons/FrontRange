//
//  Array.Remove.swift
//  FrontRange
//
//  Remove values from arrays in front matter
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

extension FrontRangeCLIEntry.Array {
  struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "remove",
      abstract: "Remove first occurrence of a value from an array in front matter",
      discussion: """
        Remove the first occurrence of a value from an array. If the value appears
        multiple times, only the first occurrence is removed.

        Files where the value is not found are skipped.

        EXAMPLES:
          # Remove "draft" tag from posts
          fr array remove --key tags --value draft posts/*.md

          # Remove specific alias
          fr array remove --key aliases --value "Old Name" post.md

        CASE SENSITIVITY:
          Use -i or --case-insensitive for case-insensitive matching:
          fr array remove --key tags --value SWIFT -i posts/*.md
        """
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .shortAndLong, help: "The front matter key (must be an array)")
    var key: String

    @Option(name: .shortAndLong, help: "The value to remove from the array")
    var value: String

    @Flag(name: [.customShort("i"), .long], help: "Case-insensitive comparison")
    var caseInsensitive: Bool = false

    func run() throws {
      printIfDebug("➖ Removing '\(value)' from array '\(key)'")
      if caseInsensitive {
        printIfDebug("📝 Case-insensitive comparison enabled")
      }

      var processedCount = 0
      var skippedCount = 0
      let paths = try options.paths

      for path in paths {
        printIfDebug("ℹ️ Processing file: \(path.string)")

        // Parse file
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)

        // Validate array exists
        let sequence = try ArrayHelpers.validateArrayKey(key, in: doc, path: path)

        // Attempt to remove value
        guard let updatedSequence = ArrayHelpers.removeFirst(
          value: value,
          from: sequence,
          caseInsensitive: caseInsensitive
        ) else {
          printIfDebug("⏭️  Skipping \(path.string): value not found")
          skippedCount += 1
          continue
        }

        doc.setValue(.sequence(updatedSequence), forKey: key)

        // Write back
        let updatedContent = try doc.render()
        try updatedContent.write(toFile: path.string, atomically: true, encoding: .utf8)
        printIfDebug("✅ Updated \(path.string)")
        processedCount += 1
      }

      // Summary output (to stderr, doesn't interfere with piping)
      if processedCount == 0 {
        fputs("No files were modified (value '\(value)' not found in any arrays)\n", stderr)
      } else {
        fputs("Updated \(processedCount) file(s)\n", stderr)
        if skippedCount > 0 {
          fputs("Skipped \(skippedCount) file(s) where value was not found\n", stderr)
        }
      }
    }
  }
}
