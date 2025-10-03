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
    
    @Argument(help: "The key to remove")
    var key: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      #if DEBUG
      print("Removing key '\(key)' from file '\(options.file)'")
      #endif
      
      let content = try String(contentsOfFile: options.file)
      var doc = try FrontMatteredDoc_Node(parsing: content)
      doc.remove(key: key)
      let updatedContent = try serializeDoc(doc)
      try updatedContent.write(to: URL(fileURLWithPath: options.file), atomically: true, encoding: .utf8)
    }
  }
}
