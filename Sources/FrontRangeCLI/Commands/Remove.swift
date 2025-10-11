//
//  Remove.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

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
      
      for path in try options.paths {
        printIfDebug("ℹ️ Removing key '\(key)' from file '\(path.string)'")
        
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)
        doc.remove(key: key)
        let updatedContent = try doc.render()
        try updatedContent.write(to: URL(fileURLWithPath: path.string), atomically: true, encoding: .utf8)
      }
    }
  }
}
