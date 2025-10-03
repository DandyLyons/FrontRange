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
    
    @Argument(help: "The key to check")
    var key: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Checking if key '\(key)' exists in file '\(options.file)' in \(options.format) format")
      
      let content = try String(contentsOfFile: options.file)
      let doc = try FrontMatteredDoc_Node(parsing: content)
      let exists = doc.hasKey(key)
      printBoolean(exists)
    }
  }
}
