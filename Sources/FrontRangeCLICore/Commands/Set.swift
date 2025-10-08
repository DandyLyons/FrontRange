//
//  Set.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

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
      for path in try options.paths {
#if DEBUG
        print("ℹ️Setting key '\(key)' to '\(value)' in file '\(path)'")
#endif
        
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc_Node(parsing: content)
        doc.setValue(value, forKey: key)
        let updatedContent = try doc.render()
        try path.write(updatedContent)
      }
    }
  }
}
