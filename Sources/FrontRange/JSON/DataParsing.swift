//
//  DataParsing.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import Foundation
#if canImport(CoreFoundation)
import CoreFoundation
#endif
import Yams

/// Errors that can occur when parsing data formats into Yams nodes
public enum DataParsingError: Error, CustomStringConvertible {
  case invalidFormat(String)
  case parseFailed(String, underlyingError: Error)
  case notAMapping(String)

  public var description: String {
    switch self {
    case .invalidFormat(let format):
      return "Unsupported format '\(format)'. Use: json, yaml, plist"
    case .parseFailed(let format, let error):
      return "Failed to parse \(format): \(error.localizedDescription)"
    case .notAMapping(let type):
      return "Front matter must be a dictionary/mapping, not a \(type)"
    }
  }
}

/// Data formats supported for parsing
public enum DataFormat: String, CaseIterable {
  case json
  case yaml
  case plist
}

/// Parse structured data string into a Yams.Node.Mapping
public func parseToMapping(
  _ data: String,
  format: DataFormat
) throws -> Yams.Node.Mapping {
  let node = try parseToNode(data, format: format)

  // Validate it's a mapping
  guard case .mapping(let mapping) = node else {
    let nodeType = nodeTypeName(node)
    throw DataParsingError.notAMapping(nodeType)
  }

  return mapping
}

/// Parse structured data string into a Yams.Node
public func parseToNode(
  _ data: String,
  format: DataFormat
) throws -> Yams.Node {
  switch format {
  case .json:
    return try parseJSONToNode(data)
  case .yaml:
    return try parseYAMLToNode(data)
  case .plist:
    return try parsePlistToNode(data)
  }
}

// MARK: - Private Helpers

private func parseJSONToNode(_ jsonString: String) throws -> Yams.Node {
  do {
    guard let data = jsonString.data(using: .utf8) else {
      throw NSError(domain: "FrontRange", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to UTF-8 data"])
    }
    let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    return nodeFromAny(obj)
  } catch {
    throw DataParsingError.parseFailed("JSON", underlyingError: error)
  }
}

private func parseYAMLToNode(_ yamlString: String) throws -> Yams.Node {
  do {
    guard let node = try Yams.compose(yaml: yamlString) else {
      throw NSError(domain: "FrontRange", code: 2, userInfo: [NSLocalizedDescriptionKey: "Empty YAML"])
    }
    return node
  } catch {
    throw DataParsingError.parseFailed("YAML", underlyingError: error)
  }
}

private func parsePlistToNode(_ plistString: String) throws -> Yams.Node {
  do {
    guard let data = plistString.data(using: .utf8) else {
      throw NSError(domain: "FrontRange", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to UTF-8 data"])
    }
    let obj = try PropertyListSerialization.propertyList(from: data, format: nil)
    return nodeFromAny(obj)
  } catch {
    throw DataParsingError.parseFailed("plist", underlyingError: error)
  }
}

private func nodeFromAny(_ any: Any) -> Yams.Node {
  // Convert Swift native type to Yams.Node
  // This is the reverse of Constructor.any(from:)
  if let dict = any as? [String: Any] {
    var pairs: [(Yams.Node, Yams.Node)] = []
    for (key, value) in dict {
      pairs.append((.scalar(.init(key)), nodeFromAny(value)))
    }
    return .mapping(.init(pairs))
  } else if let dict = any as? [AnyHashable: Any] {
    // Handle AnyHashable keys from PropertyListSerialization
    var pairs: [(Yams.Node, Yams.Node)] = []
    for (key, value) in dict {
      pairs.append((.scalar(.init(String(describing: key))), nodeFromAny(value)))
    }
    return .mapping(.init(pairs))
  } else if let array = any as? [Any] {
    return .sequence(.init(array.map(nodeFromAny)))
  } else if let string = any as? String {
    return .scalar(.init(string))
  } else if let number = any as? NSNumber {
    // Distinguish bool from number
    if CFGetTypeID(number) == CFBooleanGetTypeID() {
      return .scalar(.init(number.boolValue ? "true" : "false"))
    } else {
      return .scalar(.init(number.description))
    }
  } else if let date = any as? Date {
    let formatter = ISO8601DateFormatter()
    return .scalar(.init(formatter.string(from: date)))
  } else {
    return .scalar(.init(String(describing: any)))
  }
}

private func nodeTypeName(_ node: Yams.Node) -> String {
  switch node {
  case .scalar: return "scalar/primitive value"
  case .sequence: return "array/sequence"
  case .mapping: return "mapping/dictionary"
  case .alias: return "alias"
  }
}
