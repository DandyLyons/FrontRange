//
//  FrontMatteredDoc_Node.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-02.
//

import Foundation
import Yams

/// Experimental. A reimplementation ``FrontMatteredDoc`` that uses a `Yams.Node` for its frontmatter representation instead of a `FrontMatter` dictionary.
///
/// This type is designed to eventually replace ``FrontMatteredDoc``.
public struct FrontMatteredDoc_Node {
  public var frontMatter: Yams.Node.Mapping
  public var body: String
  
  /// Experimental. Not yet implemented.
  public var schema: [(String, Any.Type)] = []
  
  public init(
    frontMatter: Yams.Node.Mapping,
    body: String,
    schema: [(String, Any.Type)] = []
  ) {
    self.frontMatter = frontMatter
    self.body = body
    self.schema = schema
  }
}

// MARK: Computed Properties
extension FrontMatteredDoc_Node {
  public var frontMatterAsString: String {
    do {
      return try Yams.serialize(node: .mapping(self.frontMatter))
        .trimmingCharacters(in: .newlines) // remove leading/trailing newlines
    } catch {
      return ""
    }
  }
}

// MARK: Methods
extension FrontMatteredDoc_Node {
  public func hasKey(_ key: String) -> Bool {
    return self.frontMatter.keys.contains(.scalar(.init(key)))
  }
  
  public func getValue(forKey key: Yams.Node) -> Yams.Node? {
    return self.frontMatter[key]
  }
  
  public func getValue(forKey key: String) -> Yams.Node? {
    return self.frontMatter[.scalar(.init(key))]
  }
  
  mutating public func setValue(_ value: Yams.Node?, forKey key: Yams.Node) {
    self.frontMatter[key] = value
  }
  
  mutating public func setValue(_ value: Yams.Node?, forKey key: String) {
    self.frontMatter[.scalar(.init(key))] = value
  }
  
  mutating public func setValue(_ value: String, forKey key: String) {
    setValue(.scalar(.init(value)), forKey: key)
  }
  
  mutating public func setValue(_ value: Int, forKey key: String) {
    setValue(.scalar(.init("\(value)")), forKey: key)
  }
}

// MARK: Convenience Initializers
extension FrontMatteredDoc_Node {
  public init(
    parsing input: Substring,
    schema: [(String, Any.Type)] = [],
    formatting: YamsParser = YamsParser(),
  ) throws {
    var input = input
    self = try Self.Parser().parse(&input)
    self.schema = schema
  }
  
  public init(
    parsing input: String,
    schema: [(String, Any.Type)] = [],
    formatting: YamsParser = YamsParser(),
  ) throws {
    try self.init(
      parsing: Substring(input),
      schema: schema,
      formatting: formatting,
    )
  }
}
