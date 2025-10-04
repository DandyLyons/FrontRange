//
//  Node+JSON.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation
import Yams

public func nodeToJSON(_ node: Node, options: JSONSerialization.WritingOptions = []) throws -> String {
  // First, convert the Node to a Swift native type
  let constructor = Yams.Constructor.default
  let value: Any = constructor.any(from: node)
  
  // Then convert to JSON String
  if JSONSerialization.isValidJSONObject(value) {
    // `isValidJSONObject` only returns true for arrays and dictionaries
    
    let jsonData: Data = try JSONSerialization.data(
      withJSONObject: value,
      options: options
    )
    
    // Convert data to string
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw JSONConversionError.failedToConvertYamsNodeToJSON
    }
    
    return jsonString
  } else {
    // `isValidJSONObject` evaluated to false, so value is likely a primitive type
    
    switch value {
      case let string as String:
        return string
      case let stringConvertible as CustomStringConvertible:
        return stringConvertible.description
      default:
        throw JSONConversionError.failedToConvertYamsNodeToJSON
    }
  }
  
  
}

public enum JSONConversionError: Error {
  case failedToConvertYamsNodeToJSON
}

extension Yams.Node {
  /// Convert the Yams Node to a JSON string.
  /// - Throws: `JSONConversionError.failedToConvertYamsNodeToJSON` if conversion fails.
  public func toJSON(options: JSONSerialization.WritingOptions = []) throws -> String {
    return try nodeToJSON(self, options: options)
  }
}

public func yamlStringToJSON(yamlString: String, options: JSONSerialization.WritingOptions = []) throws -> String {
  guard let node = try Yams.compose(yaml: yamlString) else {
    throw JSONConversionError.failedToConvertYamsNodeToJSON
  }
  return try node.toJSON(options: options)
}

extension String {
  /// Convert a YAML string to a JSON string.
  /// - Throws: `JSONConversionError.failedToConvertYamsNodeToJSON` if conversion fails.
  public func yamlToJSON(options: JSONSerialization.WritingOptions = []) throws -> String {
    return try yamlStringToJSON(yamlString: self, options: options)
  }
}
