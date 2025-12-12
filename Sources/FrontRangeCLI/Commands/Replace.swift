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

    @OptionGroup var options: GlobalOptions

    @Option(name: .long, help: "Inline data to use as new front matter")
    var data: String?

    @Option(name: .long, help: "Path to file containing new front matter")
    var fromFile: String?

    @Option(name: [.short, .long], help: "Data format (json, yaml, plist)")
    var format: DataFormat = .json

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

      // Process each file
      for path in try options.paths {
        try replaceInFile(path: path, newFrontMatter: newFrontMatter)
      }
    }

    private func replaceInFile(path: Path, newFrontMatter: Yams.Node.Mapping) throws {
      printIfDebug("ℹ️ Processing '\(path)'")

      // Prompt for confirmation (interactive)
      print("⚠️  This will REPLACE the entire front matter in '\(path)'. Continue? (y/n): ", terminator: "")
      fflush(stdout)

      guard let response = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
        print("Cancelled (no input).")
        return
      }

      guard response == "y" || response == "yes" else {
        print("Cancelled.")
        return
      }

      // Read and parse document
      let content = try path.read(.utf8)
      var doc = try FrontMatteredDoc(parsing: content)

      // Replace front matter (direct assignment)
      doc.frontMatter = newFrontMatter

      // Render and write back
      let updatedContent = try doc.render()
      try path.write(updatedContent)

      print("✓ Replaced front matter in '\(path)'")
    }
  }
}
