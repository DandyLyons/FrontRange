//
//  Set.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

extension FrontRangeCLI {
  struct Set: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Set a value in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to set")
    var key: String
    
    @Argument(help: "The value to set")
    var value: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Setting key '\(key)' to '\(value)' in file '\(options.file)'")
      
      // Placeholder implementation:
      // let content = try String(contentsOfFile: options.file)
      // var doc = try FrontMatteredDoc(parsing: content)
      // doc.setValue(value, forKey: key)
      // let updatedContent = serializeDoc(doc)
      // try updatedContent.write(to: URL(fileURLWithPath: options.file), atomically: true, encoding: .utf8)
    }
  }
}
