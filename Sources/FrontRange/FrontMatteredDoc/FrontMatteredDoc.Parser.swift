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

    public init() {}

    public func parse(_ input: inout Substring) throws -> FrontMatteredDoc {
      // Check if input starts with frontmatter delimiter
      if input.starts(with: "---\n") {
        // Has opening delimiter → try to parse frontmatter
        var workingInput = input
        do {
          let frontMatter = try frontMatterParser.parse(&workingInput)
          // Success! Consume the input and return
          let body = String(workingInput)
          input = ""
          return FrontMatteredDoc(frontMatter: frontMatter, body: body)
        } catch {
          // Frontmatter parsing failed - check if it's due to missing closing delimiter
          // or invalid YAML/structure
          let errorDescription = String(describing: error)
          if errorDescription.contains("notAMapping") || errorDescription.contains("notANode") {
            // Invalid YAML structure → propagate error
            throw error
          } else {
            // Other error (likely no closing delimiter) → treat as no frontmatter
            let body = String(input)
            input = ""
            return FrontMatteredDoc(frontMatter: Yams.Node.Mapping(), body: body)
          }
        }
      } else {
        // No opening delimiter → empty mapping (valid case)
        let body = String(input)
        input = ""
        return FrontMatteredDoc(frontMatter: Yams.Node.Mapping(), body: body)
      }
    }

    private var frontMatterParser: some Parsing.Parser<Substring, Yams.Node.Mapping> {
      Parse(input: Substring.self) {
        "---\n"
        PrefixUpTo("---")
          .map(YAMLSubstringToNodeMappingConversion()) // Substring -> Yams.Node.Mapping
        "---"
        Optionally { "\n" }
      }
      .map { mapping, _ in mapping }
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


