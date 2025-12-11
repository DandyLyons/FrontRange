//
//  helpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

func printNodeAsYAML(node: Yams.Node) throws {
  let yamlString = try Yams.serialize(node: node)
  print(yamlString)
}

func printNodeAsJSON(node: Yams.Node) throws {
  let jsonString = try node.toJSON(options: [.prettyPrinted, .sortedKeys])
  print(jsonString)
}

func printNodeAsPlist(node: Yams.Node) throws {
  // Convert Yams.Node to Swift native type using Constructor
  let constructor = Yams.Constructor.default
  let obj = constructor.any(from: node)

  // Serialize to PropertyList XML format
  let plistData = try PropertyListSerialization.data(
    fromPropertyList: obj,
    format: .xml,
    options: 0
  )

  // Convert to string and print
  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw PlistConversionError.failedToConvertToPlist
  }
  print(plistString)
}

func anyToPlist(_ any: Any) throws -> String {
  let plistData = try PropertyListSerialization.data(
    fromPropertyList: any,
    format: .xml,
    options: 0
  )

  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw PlistConversionError.failedToConvertToPlist
  }
  return plistString
}

enum PlistConversionError: Error {
  case failedToConvertToPlist
}

public func printKeys(_ keys: [String]) {
  print("Keys:")
  print("-----")
  for key in keys {
    print(key)
  }
  print("-----")
}
