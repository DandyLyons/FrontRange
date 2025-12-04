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
    case .yaml, .plainString:
      return try Yams.serialize(node: node)
  }
}

func formatArray(_ array: [String], format: OutputFormat) throws -> String {
  switch format {
    case .json:
      return try anyToJSON(array, options: [.prettyPrinted, .sortedKeys])
    case .yaml, .plainString:
      return try anyToYAML(array)
  }
}
