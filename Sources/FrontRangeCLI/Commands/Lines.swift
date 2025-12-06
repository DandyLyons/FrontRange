//
//  Lines.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-28.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct Lines: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Extract a range of lines from a file",
      discussion: """
        If the ending line number exceeds the total number of lines in the file, then the command will return all the lines up to the end of the file.
        
        LIMITATIONS: 
        - This command is not designed to work with multiple files at once.
        """,
    )
    
    @Argument(
      help: "Path to the file to read"
    )
    var file: Path
    
    @Option(
      name: .shortAndLong,
      help: "Starting line number (1-indexed)"
    )
    var start: Int
    
    @Option(
      name: .shortAndLong,
      help: "Ending line number (1-indexed, inclusive)"
    )
    var end: Int
    
    @Flag(
      name: .shortAndLong,
      help: "Show line numbers in output"
    )
    var numbered: Bool = false
    
    func run() throws {
      // Validate line numbers
      guard start > 0 else {
        throw ValidationError("Start line must be greater than 0")
      }
      
      guard end >= start else {
        throw ValidationError("End line must be greater than or equal to start line")
      }
      
      // Read the file
      let contents = try file.read(.utf8)
      guard let lines = contents.substring(lines: start...end) else {
        throw ValidationError("File does not have enough lines to extract the specified range")
      }

      printIfDebug("ℹ️ Extracting lines \(start)-\(end) from file '\(file)'")
      let toBePrinted: String
      if numbered {
        toBePrinted = lines.split(separator: "\n", omittingEmptySubsequences: false)
          .enumerated()
          .map { index, line in
            let lineNumber = start + index
            return "\(lineNumber): \(line)"
          }.joined(separator: "\n")
      } else {
        toBePrinted = String(lines)
      }
      print(toBePrinted)
    }
  }
}
