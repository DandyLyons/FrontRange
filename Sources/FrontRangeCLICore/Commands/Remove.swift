//
//  Remove.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

extension FrontRangeCLIEntry {
  struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Remove a key from frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to remove")
    var key: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Removing key '\(key)' from file '\(options.file)'")
      
      // Placeholder implementation:
      // let content = try String(contentsOfFile: options.file)
      // var doc = try FrontMatteredDoc(parsing: content)
      // doc.frontMatter.removeValue(forKey: key)
      // let updatedContent = serializeDoc(doc)
      // try updatedContent.write(to: URL(fileURLWithPath: options.file), atomically: true, encoding: .utf8)
    }
  }
}
