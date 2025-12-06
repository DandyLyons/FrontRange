//
//  FrontMatteredDoc.Parser.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-02.
//

import Foundation
import Parsing
import Yams

extension FrontMatteredDoc {
  public struct Parser: Parsing.ParserPrinter {
    public typealias Input = Substring
    public typealias Output = FrontMatteredDoc
    
    public enum ParsingError: Swift.Error {
      /// The root object of the YAML string is not a mapping.
      case notAMapping
      /// The YAML string could not be parsed into a valid Yams `Node`.
      case notANode
    }
    
    public var body: some Parsing.Parser<Input, Output> {
      Parse(input: Substring.self) {
        FrontMatteredDoc(frontMatter: $0, body: String($1))
      } with: {
        "---\n"
        PrefixUpTo("---\n")
          .map(YAMLSubstringToNodeMappingConversion()) // Substring -> Yams.Node
        "---\n"
        Rest() // Substring -> Substring
      }
    }
    
    public func print(_ output: FrontMatteredDoc, into input: inout Substring) throws {
      input = """
              ---
              \(output.frontMatterAsString)
              ---
              \(output.body)
              """
    }
  }
}


