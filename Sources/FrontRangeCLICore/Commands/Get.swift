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
      abstract: "Get a value from frontmatter by providing its key",
      discussion: """
        This command assumes the top level of the frontmatter is a mapping (dictionary).
        
        If the key does not exist, a message is printed indicating that the key was not found.
        
        LIMITATIONS: 
        - This command can only retrieve top-level keys. Nested keys are not supported.
        """,
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
      guard let value = doc.getValue(forKey: key) else {
        print("Key '\(key)' not found in frontmatter.")
        return
      }
      switch options.format {
        case .json:
          try printNodeAsJSON(node: value)
        case .yaml, .plainString:
          try printNodeAsYAML(node: value)
      }
    }
  }
}
