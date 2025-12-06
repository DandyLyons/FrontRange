//
//  YAML Parsing.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-14.
//

import Foundation
import Parsing
import Yams

public struct YAMLSubstringToNodeMappingConversion: Conversion {
  public typealias Input = Substring
  public typealias Output = Yams.Node.Mapping
  
  public func apply(_ input: Substring) throws -> Yams.Node.Mapping {
    guard let node = try? Yams.compose(yaml: String(input)) else {
      throw FrontMatteredDoc.Parser.ParsingError.notANode
    }
    guard let mapping = node.mapping else {
      throw FrontMatteredDoc.Parser.ParsingError.notAMapping
    }
    return mapping
  }
  
  public func unapply(_ output: Yams.Node.Mapping) throws -> Substring {
    let string = try Yams.serialize(node: .mapping(output))
    return Substring(string)
  }
}

