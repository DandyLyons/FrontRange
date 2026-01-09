//
//  Array.swift
//  FrontRange
//
//  Parent command for array manipulation operations
//

import ArgumentParser

extension FrontRangeCLIEntry {
  struct Array: ParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "array",
      abstract: "Array manipulation commands for front matter",
      discussion: """
        Manipulate arrays in YAML front matter with various subcommands.

        SUBCOMMANDS:
          contains   Check if arrays contain specific values
          append     Add values to end of arrays
          prepend    Add values to beginning of arrays
          remove     Remove values from arrays

        All subcommands support:
          - Multiple file processing
          - Recursive directory traversal (with -r)
          - Date filtering (--modified-after, --created-before, etc.)
          - Debug output (FRONTRANGE_DEBUG=1)

        EXAMPLES:
          # Check if files contain a tag
          fr array contains --key tags --value swift posts/

          # Add a tag to all files
          fr array append --key tags --value tutorial posts/*.md

          # Add a tag to the front of the array
          fr array prepend --key tags --value featured posts/*.md

          # Remove a tag from files
          fr array remove --key tags --value draft posts/*.md

        PIPING:
          Array commands work great with piping for bulk operations:

          # Find files and update them
          fr array contains --key tags --value swift . | xargs fr array append --key tags --value programming
        """,
      subcommands: [Contains.self, Append.self, Prepend.self, Remove.self]
    )
  }
}
