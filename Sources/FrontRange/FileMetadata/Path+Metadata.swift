//
//  Path+Metadata.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation
import PathKit

extension Path {
  /// Get file system metadata for this path
  /// - Returns: FileMetadata containing creation, modification, and added dates
  /// - Throws: If the file doesn't exist or metadata cannot be read
  public func metadata() throws -> FileMetadata {
    try FileMetadata(path: self)
  }
}
