//
//  Array.Prepend.swift
//  FrontRange
//
//  Prepend values to beginning of arrays in front matter
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit
import Yams

extension FrontRangeCLIEntry.Array {
  struct Prepend: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "prepend",
      abstract: "Prepend a value to the beginning of an array in front matter",
      discussion: """
        Add a value to the beginning of an array in front matter. Useful for
        priority ordering (e.g., most important tag first). If the key doesn't
        exist, it will be created as a new array with the value. If the key exists
        but is not an array, an error will be thrown.

        EXAMPLES:
          # Add "featured" as first tag
          fr array prepend --key tags --value featured posts/*.md

          # Add primary alias (creates 'aliases' key if it doesn't exist)
          fr array prepend --key aliases --value "Primary Name" post.md

        SKIP DUPLICATES:
          Use --skip-duplicates to only add if value doesn't already exist:
          fr array prepend --key tags --value swift --skip-duplicates posts/*.md

        CASE INSENSITIVE:
          Use -i for case-insensitive duplicate checking:
          fr array prepend --key tags --value SWIFT -i --skip-duplicates posts/*.md
        """
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .shortAndLong, help: "The front matter key (must be an array)")
    var key: String

    @Option(name: .shortAndLong, help: "The value to prepend to the array")
    var value: String

    @Flag(name: .long, help: "Skip if value already exists in array")
    var skipDuplicates: Bool = false

    @Flag(name: [.customShort("i"), .long], help: "Case-insensitive duplicate check")
    var caseInsensitive: Bool = false

    func run() throws {
      printIfDebug("⬆️  Prepending '\(value)' to array '\(key)'")
      if skipDuplicates {
        printIfDebug("🔍 Skip duplicates enabled")
      }
      if caseInsensitive {
        printIfDebug("📝 Case-insensitive comparison enabled")
      }

      // Resolve configuration from all sources
      let resolvedConfig = try ConfigResolver.resolve(
        globalOptions: options,
        workingDirectory: Path.current
      )
      let serializationOptions = ConfigResolver.toSerializationOptions(resolvedConfig)

      let paths = try options.paths

      for path in paths {
        printIfDebug("ℹ️ Processing file: \(path.string)")

        // Parse file
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)

        // Get array (creates empty if doesn't exist, errors if not an array)
        let sequence = try ArrayHelpers.getOrCreateArrayKey(key, in: doc, path: path)

        // Check for duplicates if requested
        if skipDuplicates {
          if ArrayHelpers.containsValue(value, in: sequence, caseInsensitive: caseInsensitive) {
            printIfDebug("⏭️  Skipping \(path.string): value already exists")
            continue
          }
        }

        // Prepend value
        let updatedSequence = ArrayHelpers.prepend(value: value, to: sequence)
        doc.setValue(.sequence(updatedSequence), forKey: key)

        // Write back
        let updatedContent = try doc.render(options: serializationOptions)
        try updatedContent.write(toFile: path.string, atomically: true, encoding: .utf8)
        printIfDebug("✅ Updated \(path.string)")
      }
    }
  }
}
