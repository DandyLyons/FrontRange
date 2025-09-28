//
//  Get.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

extension FrontRangeCLIEntry {
  struct Get: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Get a value from frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to retrieve")
    var key: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Getting key '\(key)' from file '\(options.file)' in \(options.format) format")
      
      // Placeholder implementation:
      // let content = try String(contentsOfFile: options.file)
      // let doc = try FrontMatteredDoc(parsing: content)
      // let value = doc.getValue(forKey: key)
      // outputValue(value, format: options.format)
    }
  }
}
