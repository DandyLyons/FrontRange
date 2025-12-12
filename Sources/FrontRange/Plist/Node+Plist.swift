//
//  Node+Plist.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-12.
//

import Foundation
import Yams

public func nodeToPlist(_ node: Node) throws -> String {
  // First, convert the Node to a Swift native `Any` type
  let constructor = Yams.Constructor.default
  let value: Any = constructor.any(from: node)

  // Then convert to Plist String
  return try anyToPlist(value)
}

public func anyToPlist(_ any: Any) throws -> String {
  // Serialize to PropertyList XML format
  let plistData = try PropertyListSerialization.data(
    fromPropertyList: any,
    format: .xml,
    options: 0
  )

  // Convert to string
  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw PlistConversionError.failedToConvertToPlist
  }
  return plistString
}

public enum PlistConversionError: Error {
  case failedToConvertToPlist
}

extension Yams.Node {
  /// Convert the Yams Node to a PropertyList XML string.
  /// - Throws: `PlistConversionError.failedToConvertToPlist` if conversion fails.
  public func toPlist() throws -> String {
    return try nodeToPlist(self)
  }
}
