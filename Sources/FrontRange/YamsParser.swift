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
  public var resolver: Yams.Resolver
  public var constructor: Yams.Constructor
  public var encoding: Yams.Parser.Encoding
  
  public var canonical: Bool
  public var indent: Int
  public var width: Int
  public var allowUnicode: Bool
  public var lineBreak: Yams.Emitter.LineBreak
  public var explicitStart: Bool
  public var explicitEnd: Bool
  public var version: (major: Int, minor: Int)?
  public var sortKeys: Bool
  public var sequenceStyle: Yams.Node.Sequence.Style
  public var mappingStyle: Yams.Node.Mapping.Style
  public var newLineScalarStyle: Yams.Node.Scalar.Style
  public var redundancyAliasingStrategy: (any Yams.RedundancyAliasingStrategy)?
  
  
  public init(
    resolver: Yams.Resolver = .default,
    constructor: Yams.Constructor = .default,
    encoding: Yams.Parser.Encoding = .default,
    canonical: Bool = false,
    indent: Int = 2,
    width: Int = 0,
    allowUnicode: Bool = false,
    lineBreak: Yams.Emitter.LineBreak = .ln,
    explicitStart: Bool = false,
    explicitEnd: Bool = false,
    version: (major: Int, minor: Int)? = nil,
    sortKeys: Bool = false,
    sequenceStyle: Yams.Node.Sequence.Style = .any,
    mappingStyle: Yams.Node.Mapping.Style = .any,
    newLineScalarStyle: Yams.Node.Scalar.Style = .any,
    redundancyAliasingStrategy: (any Yams.RedundancyAliasingStrategy)? = nil
  ) {
    self.resolver = resolver
    self.constructor = constructor
    self.encoding = encoding
    self.canonical = canonical
    self.indent = indent
    self.width = width
    self.allowUnicode = allowUnicode
    self.lineBreak = lineBreak
    self.explicitStart = explicitStart
    self.explicitEnd = explicitEnd
    self.version = version
    self.sortKeys = sortKeys
    self.sequenceStyle = sequenceStyle
    self.mappingStyle = mappingStyle
    self.newLineScalarStyle = newLineScalarStyle
    self.redundancyAliasingStrategy = redundancyAliasingStrategy	
  }
  
  /// Serializes structured ``FrontMatter`` data into unstructured text data.
  public func print(
    _ output: FrontMatter,
    into input: inout Substring
  ) throws {
    let yamlString = try Yams.dump(
      object: output,
      canonical: canonical,
      indent: indent,
      width: width,
      allowUnicode: allowUnicode,
      lineBreak: lineBreak,
      explicitStart: explicitStart,
      explicitEnd: explicitEnd,
      version: version,
      sortKeys: sortKeys,
      sequenceStyle: sequenceStyle,
      mappingStyle: mappingStyle,
      newLineScalarStyle: newLineScalarStyle,
      redundancyAliasingStrategy: redundancyAliasingStrategy
    )
    input = yamlString.trimmingCharacters(in: .newlines) + input
  }
  
  public typealias Input = Substring
  public typealias Output = FrontMatter
  
  /// Parses unstructured text data into structured ``FrontMatter`` data.
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
