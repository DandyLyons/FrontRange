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
      guard try options.paths.count == 1 else {
        throw ValidationError("The 'list' command only supports a single file at a time.")
      }
    }
    
    func run() throws {
      let paths = try options.paths
      printIfDebug("ℹ️ Listing all keys in file '\(paths[0])' in \(options.format.rawValue) format")
      
      let content = try paths[0].read(.utf8)
      let doc = try FrontMatteredDoc(parsing: content)
      let keys = Array(doc.frontMatter.keys)
        .compactMap { $0.string }
      try printAny(
        keys,
        format: options.format
      )
    }
  }
}
