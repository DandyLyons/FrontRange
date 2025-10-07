//
//  List.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "List all keys in frontmatter",
      aliases: ["ls"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    func validate() throws {
      guard options.paths.count == 1 else {
        throw ValidationError("The 'list' command only supports a single file at a time.")
      }
    }
    
    func run() throws {
      #if DEBUG
      FrontRangeCLIEntry.logger(category: .cli)
        .log("Listing all keys in file '\(options.paths[0])' in \(options.format.rawValue) format")
      #endif
      
      let content = try options.paths[0].read(.utf8)
      let doc = try FrontMatteredDoc_Node(parsing: content)
      let keys = Array(doc.frontMatter.keys)
        .compactMap { $0.string }
      try printAny(
        keys,
        format: options.format
      )
    }
  }
}
