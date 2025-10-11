//
//  OutputFormat.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import IssueReporting
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

func print(node: Yams.Node, format: OutputFormat) throws {
  switch format {
    case .json:
      try printNodeAsJSON(node: node)
    case .yaml, .plainString:
      try printNodeAsYAML(node: node)
  }
}

func printAny(_ any: Any, format: OutputFormat) throws {
  switch format {
    case .json:
      print(try anyToJSON(any))
    case .yaml, .plainString:
      print(try anyToYAML(any))
  }
}
