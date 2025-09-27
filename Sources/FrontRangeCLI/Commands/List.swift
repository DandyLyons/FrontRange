//
//  List.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

extension FrontRangeCLI {
  struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List all keys in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Listing all keys in file '\(options.file)' in \(options.format) format")
      
      // Placeholder implementation:
      // let content = try String(contentsOfFile: options.file)
      // let doc = try FrontMatteredDoc(parsing: content)
      // let keys = Array(doc.frontMatter.keys)
      // outputKeys(keys, format: options.format)
    }
  }
}
