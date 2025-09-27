//
//  OutputFormat.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation


enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
  case json
  case yaml
  case plain
  
  var defaultValueDescription: String {
    switch self {
      case .json: return "json (default)"
      case .yaml: return "yaml"
      case .plain: return "plain"
    }
  }
}
