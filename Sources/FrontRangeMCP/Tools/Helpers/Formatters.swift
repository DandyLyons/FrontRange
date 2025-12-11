//
//  Formatters.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import Yams

func formatNode(_ node: Yams.Node, format: OutputFormat) throws -> String {
  switch format {
    case .json:
      return try nodeToJSON(node, options: [.prettyPrinted, .sortedKeys])
    case .yaml, .plainString, .raw:
      return try Yams.serialize(node: node)
    case .plist:
      return try nodeToPlist(node)
  }
}

func formatArray(_ array: [String], format: OutputFormat) throws -> String {
  switch format {
    case .json:
      return try anyToJSON(array, options: [.prettyPrinted, .sortedKeys])
    case .yaml, .plainString, .raw:
      return try anyToYAML(array)
    case .plist:
      return try anyToPlist(array)
  }
}

func nodeToPlist(_ node: Yams.Node) throws -> String {
  // Convert Yams.Node to Swift native type using Constructor
  let constructor = Yams.Constructor.default
  let obj = constructor.any(from: node)

  // Serialize to PropertyList XML format
  let plistData = try PropertyListSerialization.data(
    fromPropertyList: obj,
    format: .xml,
    options: 0
  )

  // Convert to string
  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw FormatterError.plistConversionFailed
  }
  return plistString
}

func anyToPlist(_ any: Any) throws -> String {
  let plistData = try PropertyListSerialization.data(
    fromPropertyList: any,
    format: .xml,
    options: 0
  )

  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw FormatterError.plistConversionFailed
  }
  return plistString
}

enum FormatterError: Error {
  case plistConversionFailed
}
