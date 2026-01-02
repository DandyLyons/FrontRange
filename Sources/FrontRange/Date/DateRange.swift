//
//  DateRange.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation

/// Date range for filtering and comparison operations
public struct DateRange {
  /// The start of the range (inclusive)
  public let after: Date?

  /// The end of the range (inclusive)
  public let before: Date?

  /// A specific month to match (year, month)
  public let month: (year: Int, month: Int)?

  public init(after: Date? = nil, before: Date? = nil, month: (year: Int, month: Int)? = nil) {
    self.after = after
    self.before = before
    self.month = month
  }

  // MARK: - Public API

  /// Check if a date falls within this range
  /// - Parameter date: The date to check
  /// - Returns: True if the date is within the range
  public func contains(_ date: Date) -> Bool {
    // Check month constraint first (most specific)
    if let (year, month) = month {
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month], from: date)
      if components.year != year || components.month != month {
        return false
      }
    }

    // Check after constraint
    if let after = after {
      if date < after {
        return false
      }
    }

    // Check before constraint
    if let before = before {
      if date > before {
        return false
      }
    }

    return true
  }

  /// Parse a month string in YYYY-MM format
  /// - Parameter string: The month string (e.g., "2024-01")
  /// - Returns: A tuple of (year, month) if parsing succeeds, nil otherwise
  public static func parseMonth(_ string: String) -> (year: Int, month: Int)? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    // Match YYYY-MM pattern
    let pattern = #"^(\d{4})-(\d{2})$"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return nil
    }

    let range = NSRange(trimmed.startIndex..., in: trimmed)
    guard let match = regex.firstMatch(in: trimmed, range: range),
          match.numberOfRanges >= 3 else {
      return nil
    }

    guard let yearRange = Range(match.range(at: 1), in: trimmed),
          let monthRange = Range(match.range(at: 2), in: trimmed),
          let year = Int(trimmed[yearRange]),
          let month = Int(trimmed[monthRange]) else {
      return nil
    }

    // Validate month is in range 1-12
    guard month >= 1 && month <= 12 else {
      return nil
    }

    return (year, month)
  }
}
