//
//  Has.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

extension FrontRangeCLI {
  struct Has: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Check if a key exists in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to check")
    var key: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Checking if key '\(key)' exists in file '\(options.file)' in \(options.format) format")
      
      // Placeholder implementation:
      // let content = try String(contentsOfFile: options.file)
      // let doc = try FrontMatteredDoc(parsing: content)
      // let exists = doc.hasKey(key)
      // outputBoolean(exists, format: options.format)
    }
  }
}
