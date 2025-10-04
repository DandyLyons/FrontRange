//
//  OutputFormat.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import Yams

enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
  case json
  case yaml
  case plainString
  
  var defaultValueDescription: String {
    switch self {
      case .json: return "json (default)"
      case .yaml: return "yaml"
      case .plainString: return "plainString"
    }
  }
}

func print(node: Yams.Node?, format: OutputFormat) throws {
  switch format {
    case .json:
      let jsonString = try node?.toJSON(options: [.prettyPrinted, .sortedKeys])
      print(jsonString ?? "")
    case .yaml, .plainString:
      guard let node else { print(""); return }
      let yamlString = try Yams.serialize(node: node)
      print(yamlString)
  }
}
