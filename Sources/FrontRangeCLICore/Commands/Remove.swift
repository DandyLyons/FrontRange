//
//  Remove.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Remove a key from frontmatter",
      aliases: ["rm"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to remove")
    var key: String
    
    func run() throws {
      let files = options.files
        .allFilePaths(withExtensions: options.extensions, recursively: options.recursive)
      
      for file in files {
#if DEBUG
        FrontRangeCLIEntry.logger(category: .cli)
          .log("Removing key '\(key)' from files '\(file)'")
#endif
        
        let content = try String(contentsOfFile: file)
        var doc = try FrontMatteredDoc_Node(parsing: content)
        doc.remove(key: key)
        let updatedContent = try doc.render()
        try updatedContent.write(to: URL(fileURLWithPath: file), atomically: true, encoding: .utf8)
      }
    }
  }
}
