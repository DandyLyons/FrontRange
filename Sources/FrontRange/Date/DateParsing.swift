//
//  DateParsing.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation

/// Date parsing utilities using Swift Foundation's Date.ParseStrategy API
extension Date {

  /// Parse a date string using multiple common format strategies
  /// - Parameter string: The date string to parse
  /// - Returns: A Date if parsing succeeds, nil otherwise
  public static func parse(_ string: String) -> Date? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    // Try ISO8601 first (most common for interchange)
    if let date = parseISO8601(trimmed) {
      return date
    }

    // Try YYYY-MM-DD format
    if let date = try? Date(trimmed, strategy: Date.FormatStyle()
      .year()
      .month(.twoDigits)
      .day(.twoDigits)
      .locale(Locale(identifier: "en_US_POSIX"))
      .parseStrategy) {
      return date
    }

    // Try YYYY/MM/DD format
    if let date = parseWithSeparator(trimmed, separator: "/", order: .yearMonthDay) {
      return date
    }

    // Try MM/DD/YYYY format (US)
    if let date = parseWithSeparator(trimmed, separator: "/", order: .monthDayYear) {
      return date
    }

    // Try MM-DD-YYYY format (US)
    if let date = parseWithSeparator(trimmed, separator: "-", order: .monthDayYear) {
      return date
    }

    // Try DD/MM/YYYY format (European)
    if let date = parseWithSeparator(trimmed, separator: "/", order: .dayMonthYear) {
      return date
    }

    // Try DD-MM-YYYY format (European)
    if let date = parseWithSeparator(trimmed, separator: "-", order: .dayMonthYear) {
      return date
    }

    return nil
  }

  // MARK: - Private Helpers

  private enum ComponentOrder {
    case yearMonthDay
    case monthDayYear
    case dayMonthYear
  }

  private static func parseISO8601(_ string: String) -> Date? {
    // Try standard ISO8601 with time
    if let date = try? Date(string, strategy: .iso8601) {
      return date
    }

    // Try date-only ISO8601 (YYYY-MM-DD)
    let iso8601DateOnly = Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
      .year()
      .month()
      .day()

    if let date = try? Date(string, strategy: iso8601DateOnly) {
      return date
    }

    return nil
  }

  private static func parseWithSeparator(_ string: String, separator: String, order: ComponentOrder) -> Date? {
    // Use DateFormatter for non-standard separators and orderings
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)

    switch order {
    case .yearMonthDay:
      formatter.dateFormat = "yyyy\(separator)MM\(separator)dd"
    case .monthDayYear:
      formatter.dateFormat = "MM\(separator)dd\(separator)yyyy"
    case .dayMonthYear:
      formatter.dateFormat = "dd\(separator)MM\(separator)yyyy"
    }

    return formatter.date(from: string)
  }
}
