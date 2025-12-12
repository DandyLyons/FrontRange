//
//  Logger+FrontRangeCLICore.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation
#if canImport(OSLog)
import OSLog
#endif

extension FrontRangeCLIEntry {
  enum Category: String {
    case cli
  }
  #if canImport(OSLog)
  static func logger(category: Self.Category) -> Logger {
    return Logger(subsystem: "com.daniellyons.FrontRangeCLICore", category: category.rawValue)
  }
  #endif
}
