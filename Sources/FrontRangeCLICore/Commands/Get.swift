//
//  Get.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Get: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Get a value from frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to retrieve")
    var key: String
    
    func run() throws {
      #if DEBUG
      
      print("ℹ️ Getting key '\(key)' from file '\(options.file)' in \(options.format) format")
      #endif
      
      let content = try String(contentsOfFile: options.file)
      let doc = try FrontMatteredDoc_Node(parsing: content)
      let value = doc.getValue(forKey: key)
//      printValue(value)
      print(String(describing: value))
    }
  }
}
