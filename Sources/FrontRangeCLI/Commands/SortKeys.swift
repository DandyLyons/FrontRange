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
import PathKit

extension FrontRangeCLIEntry {
  struct SortKeys: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Sort keys in frontmatter",
      aliases: ["sk"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(help: "The sorting method to use (alphabetical, length)")
    var sortMethod: SortMethod = .alphabetical
    
    @Flag(help: "Reverse the sorting order")
    var reverse: Bool = false
    
    enum SortMethod: String, CaseIterable, ExpressibleByArgument {
      case alphabetical
      case length
    }
      
    
    func run() throws {
      // Resolve configuration from all sources
      let resolvedConfig = try ConfigResolver.resolve(
        globalOptions: options,
        workingDirectory: Path.current
      )
      let serializationOptions = ConfigResolver.toSerializationOptions(resolvedConfig)

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

        if reverse {
          doc.frontMatter.reverse()
        }

        let updatedContent = try doc.render(options: serializationOptions)
        try path.write(updatedContent)
      }
    }
  }
}
