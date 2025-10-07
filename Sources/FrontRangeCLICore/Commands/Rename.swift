//
//  Rename.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/28/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Rename: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Rename a key from frontmatter",
      aliases: ["rn"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to rename")
    var key: String
    
    @Option(help: "The new key name")
    var newKey: String
    
    func run() throws {
      for path in options.paths {
#if DEBUG
        FrontRangeCLIEntry.logger(category: .cli)
          .log("Renaming key '\(key)' to '\(newKey)' inside file '\(path.absolute())'")
#endif
        
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc_Node(parsing: content)
        try doc.renameKey(from: key, to: newKey)
        let updatedContent = try doc.render()
        try path.write(updatedContent)
      }
    }
  }
}
