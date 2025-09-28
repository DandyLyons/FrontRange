//
//  Rename.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/28/25.
//

import ArgumentParser
import Foundation
import FrontRange

extension FrontRangeCLIEntry {
  struct Rename: ParsableCommand {
    static let configuration = CommandConfiguration(
      abstract: "Rename a key from frontmatter",
      aliases: ["rn"],
    )
    
    @OptionGroup var options: GlobalOptions
    
    @Argument(help: "The key to rename")
    var key: String
    
    @Argument(help: "The new key name")
    var newKey: String
    
    func run() throws {
      // TODO: Implement using FrontRange
      #if DEBUG
      print("Renaming key '\(key)' to '\(newKey)' inside file '\(options.file)'")
      #endif
      
      let content = try String(contentsOfFile: options.file)
      var doc = try FrontMatteredDoc(parsing: content)
      guard doc.hasKey(key),
      let keyIndex = doc.frontMatter.index(forKey: key) else {
        throw ValidationError("Key '\(key)' does not exist in frontmatter")
      }
      
      let value = doc.frontMatter.remove(at: keyIndex).value
      
      doc.frontMatter.updateValue(value, forKey: newKey, insertingAt: keyIndex)
      let updatedContent = try serializeDoc(doc)
      try updatedContent.write(to: URL(fileURLWithPath: options.file), atomically: true, encoding: .utf8)
    }
  }
}
