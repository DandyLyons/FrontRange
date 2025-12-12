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
  case raw
  case plist

  var defaultValueDescription: String {
    switch self {
      case .json: return "json (default)"
      case .yaml: return "yaml"
      case .plainString: return "plainString"
      case .raw: return "raw"
      case .plist: return "plist"
    }
  }
}

func print(node: Yams.Node, format: OutputFormat) throws {
  switch format {
    case .json:
      try printNodeAsJSON(node: node)
    case .yaml, .plainString, .raw:
      try printNodeAsYAML(node: node)
    case .plist:
      try printNodeAsPlist(node: node)
  }
}

func printAny(_ any: Any, format: OutputFormat) throws {
  switch format {
    case .json:
      print(try anyToJSON(any))
    case .yaml, .plainString, .raw:
      print(try anyToYAML(any))
    case .plist:
      print(try anyToPlist(any))
  }
}
