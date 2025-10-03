//
//  helpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange

public func printValue(_ value: Any?) {
  outputValue(value, format: .plain)
}

// These would be implemented to handle the actual FrontRange operations and formatting

private func outputValue(_ value: Any?, format: OutputFormat) {
  switch value {
    case let stringValue as String:
      print(stringValue)
    case let intValue as Int:
      print(intValue)
    case let doubleValue as Double:
      print(doubleValue)
    case let boolValue as Bool:
      outputBoolean(boolValue, format: format)
    case let arrayValue as [Any]:
      // Handle array output recursively
      for value in arrayValue {
        outputValue(value, format: format)
      }
    case let dictValue as [String: Any]:
      print("🔴 Dictionary output not yet implemented")
//    case let orderedDictValue as FrontMatter:
//      print("🔴 FrontMatter (OrderedDictionary) output not yet implemented")
    default:
      print("🔴 Unsupported value: \(String(describing: value))")
  }
}

public func printBoolean(_ value: Bool) {
  outputBoolean(value, format: .plain)
}

private func outputBoolean(_ value: Bool, format: OutputFormat) {
  if value {
    print("true")
  } else {
    print("false")
  }
}

public func printKeys(_ keys: [String]) {
  outputKeys(keys, format: .plain)
}
  

private func outputKeys(_ keys: [String], format: OutputFormat) {
  print("Keys:")
  print("-----")
  for key in keys {
    print(key)
  }
  print("-----")
}

public func serializeDoc(_ doc: FrontMatteredDoc_Node) throws -> String {
  return try doc.render()
}
