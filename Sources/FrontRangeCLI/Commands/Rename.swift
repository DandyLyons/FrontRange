//
//  Rename.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/28/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

extension FrontRangeCLIEntry {
  struct Rename: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Rename a key from frontmatter",
      aliases: ["rn"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Option(name: .shortAndLong,
      help: "The key to rename")
    var key: String
    
    @Option(help: "The new key name")
    var newKey: String
    
    func run() throws {
      // Resolve configuration from all sources
      let resolvedConfig = try ConfigResolver.resolve(
        globalOptions: options,
        workingDirectory: Path.current
      )
      let serializationOptions = ConfigResolver.toSerializationOptions(resolvedConfig)

      for path in try options.paths {
        printIfDebug("ℹ️ Renaming key '\(key)' to '\(newKey)' inside file '\(path.absolute())'")

        let content = try path.read(.utf8)
        var doc = try FrontMatteredDoc(parsing: content)
        try doc.renameKey(from: key, to: newKey)
        let updatedContent = try doc.render(options: serializationOptions)
        try path.write(updatedContent)
      }
    }
  }
}
