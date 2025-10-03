//
//  FrontMatter+Yams.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/20/25.
//

import Foundation
import OrderedCollections
import Yams

extension FrontMatter: @retroactive NodeRepresentable {
  public func represented() throws -> Node {
    var pairs: [(Node, Node)] = []
    
    for (key, value) in self {
      let keyNode = Node(key)
      let valueNode = try nodeFromAny(value)
      pairs.append((keyNode, valueNode))
    }
    
    return Node(pairs)
  }
}

private func nodeFromAny(_ value: Any) throws -> Node {
  enum YamsNodeError: Error {
    case unsupportedValueType
  }
  
  switch value {
    case let string as String:
      return Node(string)
    case let int as Int:
      return try Node(int)
    case let double as Double:
      return try Node(double)
    case let bool as Bool:
      return try Node(bool)
    case let array as [Any]:
      let nodes = try array.map { try nodeFromAny($0) }
      return Node(nodes)
    case let dict as [String: Any]:
      let pairs = try dict.map { (key, val) -> (Node, Node) in
        return (Node(key), try nodeFromAny(val))
      }
      return Node(pairs)
    case let orderedDict as OrderedDictionary<String, Any>:
      let pairs = try orderedDict.map { (key, val) -> (Node, Node) in
        return (Node(key), try nodeFromAny(val))
      }
      return Node(pairs)
    default:
      throw YamsNodeError.unsupportedValueType
  }
}
