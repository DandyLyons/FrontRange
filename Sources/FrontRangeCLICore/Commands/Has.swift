//
//  Has.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Has: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Check if a key exists in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to check for")
    var key: String
    
    func run() throws {
      var filesWithKey: [String] = []
      var filesWithoutKey: [String] = []
      
      let files = options.files
        .allFilePaths(withExtensions: options.extensions, recursively: options.recursive)
      
      for file in files {
        
#if DEBUG
        FrontRangeCLIEntry.logger(category: .cli)
          .log("Checking if key '\(key)' exists in files '\(options.files.commaSeparated())' in \(options.format.rawValue) format")
#endif
        
        let content = try String(contentsOfFile: file)
        let doc = try FrontMatteredDoc_Node(parsing: content)
        if doc.hasKey(key) {
          filesWithKey.append(file)
        } else {
          filesWithoutKey.append(file)
        }
      }
      print("""
      Files containing key '\(key)':
      \(filesWithKey.isEmpty ? "None" : filesWithKey.joined(separator: "\n"))
      
      Files NOT containing key '\(key)':
      \(filesWithoutKey.isEmpty ? "None" : filesWithoutKey.joined(separator: "\n"))
      """)
    }
  }
}
