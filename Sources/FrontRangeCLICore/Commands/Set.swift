//
//  Set.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Set: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Set a value in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to set")
    var key: String
    
    @Option(help: "The value to set")
    var value: String
    
    func run() throws {
      let files = options.files
        .allFilePaths(withExtensions: options.extensions, recursively: options.recursive)
      
      for file in files {
#if DEBUG
        FrontRangeCLIEntry.logger(category: .cli)
          .log("ℹ️Setting key '\(key)' to '\(value)' in file '\(file)'")
#endif
        
        // Placeholder implementation:
        let content = try String(contentsOfFile: file)
        var doc = try FrontMatteredDoc_Node(parsing: content)
        doc.setValue(value, forKey: key)
        let updatedContent = try doc.render()
        try updatedContent.write(to: URL(fileURLWithPath: file), atomically: true, encoding: .utf8)
      }
    }
  }
}
