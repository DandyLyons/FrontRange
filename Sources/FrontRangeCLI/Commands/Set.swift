//
//  Set.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct Set: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Set a value in frontmatter"
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to set")
    var key: String
    
    @Option(help: "The value to set")
    var value: String
    
    func run() throws {
      // Resolve configuration from all sources
      let resolvedConfig = try ConfigResolver.resolve(
        globalOptions: options,
        workingDirectory: Path.current
      )
      let serializationOptions = ConfigResolver.toSerializationOptions(resolvedConfig)

      for path in try options.paths {
        printIfDebug("ℹ️Setting key '\(key)' to '\(value)' in file '\(path)'")

        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)
        doc.setValue(value, forKey: key)
        let updatedContent = try doc.render(options: serializationOptions)
        try path.write(updatedContent)
      }
    }
  }
}
