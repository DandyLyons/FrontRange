//
//  YamsParser.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/3/25.
//

import Foundation
import Parsing
import Yams

/// A `swift-parsing` wrapper around the `Yams` YAML parser that parses a YAML document into a `FrontMatter`.
public struct YamsParser: Parsing.ParserPrinter {
  var resolver: Yams.Resolver
  var constructor: Yams.Constructor
  var encoding: Yams.Parser.Encoding
  
  public init(
    resolver: Yams.Resolver = .default,
    constructor: Yams.Constructor = .default,
    encoding: Yams.Parser.Encoding = .default
  ) {
    self.resolver = resolver
    self.constructor = constructor
    self.encoding = encoding
  }
  
  public func print(
    _ output: FrontMatter,
    into input: inout Substring
  ) throws {
    let dict: [String: Any] = output.reduce(into: [:]) { $0[$1.key] = $1.value }
    let yamlString = try Yams.dump(object: dict)
    input = Substring(yamlString.trimmingCharacters(in: .newlines)) + input
  }
  
  public typealias Input = Substring
  public typealias Output = FrontMatter
  
  public func parse(_ input: inout Substring) throws -> FrontMatter {
    Swift.print("ℹ️ Parsing input string:\n\(input)")
    
    let dict = try Yams.load(
      yaml: String(input),
      self.resolver,
      self.constructor,
      self.encoding,
    )
    guard let dict = dict as? FrontMatter else {
      throw Error.notADictionary
    }
    
    input = Substring() // Clear the input since we consumed the entire YAML document
    return dict
  }
}

extension YamsParser {
  public enum Error: Swift.Error {
    case notADictionary
    
    public var errorDescription: String? {
      switch self {
      case .notADictionary:
        return "The top level of the YAML document is not a `FrontMatter`."
      }
    }
  }
}
