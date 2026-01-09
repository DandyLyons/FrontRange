//
//  Array.Append.swift
//  FrontRange
//
//  Append values to end of arrays in front matter
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

extension FrontRangeCLIEntry.Array {
  struct Append: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "append",
      abstract: "Append a value to the end of an array in front matter",
      discussion: """
        Add a value to the end of an array in front matter. If the array doesn't
        exist, this command will throw an error.

        EXAMPLES:
          # Add "tutorial" tag to all posts
          fr array append --key tags --value tutorial posts/*.md

          # Add alias to specific file
          fr array append --key aliases --value "New Alias" post.md

        SKIP DUPLICATES:
          Use --skip-duplicates to only add if value doesn't already exist:
          fr array append --key tags --value swift --skip-duplicates posts/*.md

        CASE INSENSITIVE:
          Use -i for case-insensitive duplicate checking:
          fr array append --key tags --value SWIFT -i --skip-duplicates posts/*.md
        """
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .shortAndLong, help: "The front matter key (must be an array)")
    var key: String

    @Option(name: .shortAndLong, help: "The value to append to the array")
    var value: String

    @Flag(name: .long, help: "Skip if value already exists in array")
    var skipDuplicates: Bool = false

    @Flag(name: [.customShort("i"), .long], help: "Case-insensitive duplicate check")
    var caseInsensitive: Bool = false

    func run() throws {
      printIfDebug("➕ Appending '\(value)' to array '\(key)'")
      if skipDuplicates {
        printIfDebug("🔍 Skip duplicates enabled")
      }
      if caseInsensitive {
        printIfDebug("📝 Case-insensitive comparison enabled")
      }

      let paths = try options.paths

      for path in paths {
        printIfDebug("ℹ️ Processing file: \(path.string)")

        // Parse file
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)

        // Validate array exists
        let sequence = try ArrayHelpers.validateArrayKey(key, in: doc, path: path)

        // Check for duplicates if requested
        if skipDuplicates {
          if ArrayHelpers.containsValue(value, in: sequence, caseInsensitive: caseInsensitive) {
            printIfDebug("⏭️  Skipping \(path.string): value already exists")
            continue
          }
        }

        // Append value
        let updatedSequence = ArrayHelpers.append(value: value, to: sequence)
        doc.setValue(.sequence(updatedSequence), forKey: key)

        // Write back
        let updatedContent = try doc.render()
        try updatedContent.write(toFile: path.string, atomically: true, encoding: .utf8)
        printIfDebug("✅ Updated \(path.string)")
      }
    }
  }
}
