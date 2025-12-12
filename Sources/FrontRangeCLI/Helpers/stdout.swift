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
  let plistString = try nodeToPlist(node)
  print(plistString)
}

public func printKeys(_ keys: [String]) {
  print("Keys:")
  print("-----")
  for key in keys {
    print(key)
  }
  print("-----")
}
