//
//  List.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List all keys in frontmatter",
      aliases: ["ls"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    func run() throws {
      // TODO: Implement using FrontRange
      print("Listing all keys in file '\(options.file)' in \(options.format) format")
      
      let content = try String(contentsOfFile: options.file)
      let doc = try FrontMatteredDoc_Node(parsing: content)
      print(doc.frontMatter.keys)
    }
  }
}
