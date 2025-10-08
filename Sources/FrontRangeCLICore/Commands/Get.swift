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
    
    @Option(name: .shortAndLong,
      help: "The key to get")
    var key: String
    
    
    
    func run() throws {
      
      for path in try options.paths {
#if DEBUG
        print("ℹ️ Getting key '\(key)' from file '\(path)' in \(options.format.rawValue) format")
#endif
        
        let content = try path.read(.utf8)
        let doc = try FrontMatteredDoc_Node(parsing: content)
        guard let value = doc.getValue(forKey: key) else {
          print("Key '\(key)' not found in frontmatter.")
          return
        }
        
        try print(node: value, format: options.format)
      }
    }
  }
}
