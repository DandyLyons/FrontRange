//
//  File.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/15/25.
//

import Foundation
import Parsing

/// A parser that extracts keys from a YAML front matter section.
///
/// Expects pure YAML with:
/// 1. No `---` delimiters.
/// 2. Mapping keys only (the root of the object is a dictionary).
///
/// Returns an array of keys as strings.
public struct YAMLKeysParser: Parser {
  public typealias Input = Substring
  public typealias Output = [String]
  
  public init() {}

  public func parse(_ input: inout Substring) throws -> [String] {
    var results: [String] = []
    let lines: [Substring] = input.split(separator: "\n", omittingEmptySubsequences: true)
    for line in lines {
      if line.starts(with: "#") {
        // Skip comment lines
        continue
      }
      
      // check if line starts with whitespace (indicating a nested key)
      if let first = line.first, first.isWhitespace {
        continue
      }

      if let colonIndex = line.firstIndex(of: ":") {
        let key = line[..<colonIndex].trimmingCharacters(in: .whitespaces)
        results.append(String(key))
      } else {
        // No colon found, skip this line
        continue
      }
    }
    
    input = ""
    return results
  }
}

