//
//  ValidateOutputFormat.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import ArgumentParser
import Foundation

/// Output formats for the validate command
enum ValidateOutputFormat: String, ExpressibleByArgument {
  case detailed
  case summary
  case json
  case yaml

  var defaultValueDescription: String {
    "detailed"
  }
}
