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
      for path in try options.paths {
        printIfDebug("ℹ️ Sorting keys in file '\(path)' using method '\(sortMethod.rawValue)'")
        
        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)
        
        switch sortMethod {
          case .alphabetical:
            doc.frontMatter.sort { $0.key < $1.key }
          case .length:
            //          doc.frontMatter.sort { $0.key.count < $1.key.count }
            reportIssue("Not yet implemented: sorting by length")
        }
        
        let updatedContent = try doc.render()
        try path.write(updatedContent)
      }
    }
  }
}
