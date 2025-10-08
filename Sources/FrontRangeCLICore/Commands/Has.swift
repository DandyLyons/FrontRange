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
      let paths = try options.paths
      
      for path in paths {
        
#if DEBUG
        print("ℹ️ Checking if key '\(key)' exists in files '\(paths)' in \(options.format.rawValue) format")
#endif
        
        let content = try path.read(.utf8)
        let doc = try FrontMatteredDoc_Node(parsing: content)
        if doc.hasKey(key) {
          filesWithKey.append(path.absolute().string)
        } else {
          filesWithoutKey.append(path.absolute().string)
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
