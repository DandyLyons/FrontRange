//
//  SortKeys.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/28/25.
//

import ArgumentParser
import Foundation
import FrontRange
import IssueReporting

extension FrontRangeCLIEntry {
  struct SortKeys: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Sort keys in frontmatter",
      aliases: ["sk"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(help: "The sorting method to use (alphabetical, length)")
    var sortMethod: SortMethod = .alphabetical
    
    enum SortMethod: String, CaseIterable, ExpressibleByArgument {
      case alphabetical
      case length
    }
      
    
    func run() throws {
      // TODO: Implement using FrontRange
      #if DEBUG
      print("Sorting keys in file '\(options.file)' using method '\(sortMethod)'")
      #endif
      
      let content = try String(contentsOfFile: options.file)
      var doc = try FrontMatteredDoc_Node(parsing: content)
      
      switch sortMethod {
        case .alphabetical:
          doc.frontMatter.sort { $0.key < $1.key }
        case .length:
//          doc.frontMatter.sort { $0.key.count < $1.key.count }
          reportIssue("Not yet implemented: sorting by length")
      }
      
      let updatedContent = try serializeDoc(doc)
      try updatedContent.write(to: URL(fileURLWithPath: options.file), atomically: true, encoding: .utf8)
    }
  }
}
