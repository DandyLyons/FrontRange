//
//  FileMetadata.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation
import PathKit

#if os(macOS)
import CoreServices
#endif

/// File system metadata including dates
public struct FileMetadata {
  /// The file path
  public let path: Path

  /// File creation date
  public let creationDate: Date?

  /// File modification date
  public let modificationDate: Date?

  /// File added date (macOS only, via Spotlight metadata)
  public let addedDate: Date?

  /// Initialize file metadata for a given path
  /// - Parameter path: The file path to get metadata for
  /// - Throws: If the file doesn't exist or metadata cannot be read
  public init(path: Path) throws {
    self.path = path

    let attrs = try FileManager.default.attributesOfItem(atPath: path.string)
    self.creationDate = attrs[.creationDate] as? Date
    self.modificationDate = attrs[.modificationDate] as? Date

    // macOS-specific: Try to get "added date" via Spotlight metadata
    #if os(macOS)
    self.addedDate = Self.getAddedDate(for: path)
    #else
    self.addedDate = nil
    #endif
  }

  // MARK: - Date Matching

  /// Check if modification date matches the given constraints
  /// - Parameters:
  ///   - after: The date must be after this (inclusive)
  ///   - before: The date must be before this (inclusive)
  ///   - month: The date must be in this month (year, month)
  /// - Returns: True if the modification date matches all constraints
  public func matchesModified(after: Date?, before: Date?, month: (Int, Int)?) -> Bool {
    guard let date = modificationDate else {
      return false
    }
    return matches(date: date, after: after, before: before, month: month)
  }

  /// Check if creation date matches the given constraints
  /// - Parameters:
  ///   - after: The date must be after this (inclusive)
  ///   - before: The date must be before this (inclusive)
  ///   - month: The date must be in this month (year, month)
  /// - Returns: True if the creation date matches all constraints
  public func matchesCreated(after: Date?, before: Date?, month: (Int, Int)?) -> Bool {
    guard let date = creationDate else {
      return false
    }
    return matches(date: date, after: after, before: before, month: month)
  }

  /// Check if added date matches the given constraints
  /// - Parameters:
  ///   - after: The date must be after this (inclusive)
  ///   - before: The date must be before this (inclusive)
  ///   - month: The date must be in this month (year, month)
  /// - Returns: True if the added date matches all constraints
  public func matchesAdded(after: Date?, before: Date?, month: (Int, Int)?) -> Bool {
    guard let date = addedDate else {
      return false
    }
    return matches(date: date, after: after, before: before, month: month)
  }

  // MARK: - Private Helpers

  private func matches(date: Date, after: Date?, before: Date?, month: (Int, Int)?) -> Bool {
    // Check month constraint first (most specific)
    if let (year, monthValue) = month {
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month], from: date)
      if components.year != year || components.month != monthValue {
        return false
      }
    }

    // Check after constraint (inclusive)
    if let after = after, date < after {
      return false
    }

    // Check before constraint (inclusive)
    if let before = before, date > before {
      return false
    }

    return true
  }

  #if os(macOS)
  /// Get the "added date" for a file using Spotlight metadata (macOS only)
  /// - Parameter path: The file path
  /// - Returns: The added date if available, nil otherwise
  private static func getAddedDate(for path: Path) -> Date? {
    guard let mdItem = MDItemCreate(nil, path.string as CFString) else {
      return nil
    }

    guard let addedDateRef = MDItemCopyAttribute(mdItem, kMDItemDateAdded) else {
      return nil
    }

    // The attribute is a CFDate, which is toll-free bridged to Date
    return addedDateRef as? Date
  }
  #endif
}
