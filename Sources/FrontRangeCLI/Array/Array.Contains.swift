//
//  Array.Contains.swift
//  FrontRange
//
//  Check if arrays in front matter contain specific values
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

extension FrontRangeCLIEntry.Array {
  struct Contains: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "contains",
      abstract: "Find files where an array contains a specific value",
      discussion: """
        Search for files whose front matter contains an array with a specific value.

        This command performs case-sensitive string comparison only.
        Currently, boolean, null, integer, and float values are not supported.

        Files where the key doesn't exist or the value is not an array are silently
        skipped (use --debug to see these cases).

        EXAMPLES:
          # Find files where tags array contains "swift"
          fr array contains --key tags --value swift posts/

          # Find files with specific alias
          fr array contains --key aliases --value Blue ./

        PIPING TO OTHER COMMANDS:
          The command outputs file paths (one per line), making it ideal for piping:

          # Bulk update: mark all posts tagged "swift" as published
          fr array contains --key tags --value swift posts/ | xargs fr set --key published --value true

          # Chain operations
          fr array contains --key tags --value tutorial . | while read -r file; do
            fr set "$file" --key featured --value true
          done

          # Find and list front matter
          fr array contains --key categories --value tech . | xargs fr list

        OUTPUT FORMATS:
          --format plainString (default): One file path per line
          --format json: JSON array of file paths
          --format yaml: YAML list of file paths

        INVERT RESULTS:
          Use --invert to find files that DON'T contain the value:
          fr array contains --key tags --value deprecated --invert posts/
        """
    )

    @OptionGroup var options: GlobalOptions

    @Option(name: .shortAndLong, help: "The front matter key to check (must be an array)")
    var key: String

    @Option(name: .shortAndLong, help: "The value to search for in the array (string comparison only)")
    var value: String

    @Flag(name: .long, help: "Invert results: show files that DON'T contain the value")
    var invert: Bool = false

    @Flag(name: [.customShort("i"), .long], help: "Case-insensitive comparison")
    var caseInsensitive: Bool = false

    func run() throws {
      printIfDebug("🔍 Searching for '\(value)' in array '\(key)'")
      if invert {
        printIfDebug("🔄 Inverted mode: finding files WITHOUT the value")
      }
      if caseInsensitive {
        printIfDebug("📝 Case-insensitive comparison enabled")
      }

      var matchingFiles: [String] = []
      let paths = try options.paths

      for path in paths {
        printIfDebug("ℹ️ Checking file: \(path.string)")

        // 1. Parse file
        let content: String
        let doc: FrontMatteredDoc
        do {
          content = try path.read(.utf8)
          doc = try FrontMatteredDoc(parsing: content)
        } catch {
          printIfDebug("⚠️ Failed to parse \(path.string): \(error.localizedDescription) - skipping")
          continue
        }

        // 2. Check if key exists and is an array (skip if not)
        let sequence: Yams.Node.Sequence
        do {
          sequence = try ArrayHelpers.validateArrayKey(key, in: doc, path: path)
        } catch {
          printIfDebug("⚠️ \(error.localizedDescription) - skipping")
          continue
        }

        // 3. Search for the value in the sequence
        let found = ArrayHelpers.containsValue(value, in: sequence, caseInsensitive: caseInsensitive)

        // 4. Apply invert logic
        let matches = invert ? !found : found

        if matches {
          matchingFiles.append(path.absolute().string)
          printIfDebug("✅ Match: \(path.string)")
        } else {
          printIfDebug("❌ No match: \(path.string)")
        }
      }

      // 5. Output results
      try outputResults(matchingFiles)
    }

    private func outputResults(_ matchingFiles: [String]) throws {
      if matchingFiles.isEmpty {
        // Print to stderr so it doesn't interfere with piping
        let invertMsg = invert ? " NOT" : ""
        fputs("No files found where '\(key)' array\(invertMsg) contains '\(value)'\n", stderr)
        Foundation.exit(1)
      } else {
        switch options.format {
        case .json:
          try printAny(matchingFiles, format: .json)
        case .yaml:
          try printAny(matchingFiles, format: .yaml)
        case .plainString, .raw:
          print(matchingFiles.joined(separator: "\n"))
        case .plist:
          try printAny(matchingFiles, format: .plist)
        }
        Foundation.exit(0)
      }
    }
  }
}
