//
//  Logger+FrontRangeCLICore.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation
import OSLog

extension FrontRangeCLIEntry {
  enum Category: String {
    case cli
  }
  static func logger(category: Self.Category) -> Logger {
    return Logger(subsystem: "com.daniellyons.FrontRangeCLICore", category: category.rawValue)
  }
}
