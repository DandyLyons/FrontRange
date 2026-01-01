//
//  DateParser.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation

/// Multi-format date parser with automatic format detection
public struct DateParser {

  /// Supported date formats
  public enum Format {
    case iso8601
    case yearMonthDay(separator: Character)  // YYYY-MM-DD, YYYY/MM/DD
    case monthDayYear(separator: Character)  // MM/DD/YYYY, MM-DD-YYYY
    case dayMonthYear(separator: Character)  // DD/MM/YYYY, DD-MM-YYYY
    case custom(String)  // Custom DateFormatter format string

    /// Get DateFormatter for this format
    func formatter() -> DateFormatter? {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)

      switch self {
      case .iso8601:
        // ISO8601 handled separately
        return nil
      case .yearMonthDay(let sep):
        formatter.dateFormat = "yyyy\(sep)MM\(sep)dd"
      case .monthDayYear(let sep):
        formatter.dateFormat = "MM\(sep)dd\(sep)yyyy"
      case .dayMonthYear(let sep):
        formatter.dateFormat = "dd\(sep)MM\(sep)yyyy"
      case .custom(let formatString):
        formatter.dateFormat = formatString
      }

      return formatter
    }
  }

  // MARK: - Public API

  /// Parse a date string with automatic format detection
  /// - Parameter string: The date string to parse
  /// - Returns: A Date if parsing succeeds, nil otherwise
  public static func parse(_ string: String) -> Date? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    // Try ISO 8601 first (most common for interchange)
    if let date = parseISO8601(trimmed) {
      return date
    }

    // Detect likely format based on pattern
    if let detectedFormat = detectFormat(trimmed) {
      return parse(trimmed, format: detectedFormat)
    }

    // Try common formats as fallback
    for format in commonFormats() {
      if let date = parse(trimmed, format: format) {
        return date
      }
    }

    return nil
  }

  /// Parse a date string with an explicit format
  /// - Parameters:
  ///   - string: The date string to parse
  ///   - format: The format to use for parsing
  /// - Returns: A Date if parsing succeeds, nil otherwise
  public static func parse(_ string: String, format: Format) -> Date? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    if case .iso8601 = format {
      return parseISO8601(trimmed)
    }

    guard let formatter = format.formatter() else {
      return nil
    }

    return formatter.date(from: trimmed)
  }

  /// Check if a string looks like it might be a date
  /// - Parameter string: The string to check
  /// - Returns: True if the string matches common date patterns
  public static func looksLikeDate(_ string: String) -> Bool {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    // Common date patterns
    let patterns = [
      #"^\d{4}[-/]\d{2}[-/]\d{2}"#,  // YYYY-MM-DD or YYYY/MM/DD
      #"^\d{2}[-/]\d{2}[-/]\d{4}"#,  // MM-DD-YYYY or DD-MM-YYYY
      #"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"#,  // ISO 8601 with time
    ]

    for pattern in patterns {
      if trimmed.range(of: pattern, options: .regularExpression) != nil {
        return true
      }
    }

    return false
  }

  // MARK: - Private Helpers

  private static func parseISO8601(_ string: String) -> Date? {
    let formatter = ISO8601DateFormatter()

    // Try with fractional seconds
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: string) {
      return date
    }

    // Try standard ISO8601
    formatter.formatOptions = [.withInternetDateTime]
    if let date = formatter.date(from: string) {
      return date
    }

    // Try date-only format (YYYY-MM-DD)
    formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    if let date = formatter.date(from: string) {
      return date
    }

    return nil
  }

  private static func detectFormat(_ string: String) -> Format? {
    // YYYY-MM-DD or YYYY/MM/DD (most unambiguous)
    if let match = string.range(of: #"^(\d{4})([-/])(\d{2})\2(\d{2})$"#, options: .regularExpression) {
      let separator = string[match].contains("-") ? "-" : "/"
      return .yearMonthDay(separator: Character(separator))
    }

    // MM/DD/YYYY or MM-DD-YYYY (US format)
    if let match = string.range(of: #"^(\d{2})([-/])(\d{2})\2(\d{4})$"#, options: .regularExpression) {
      let separator = string[match].contains("-") ? "-" : "/"
      // Ambiguous: could be MM/DD or DD/MM
      // Default to US format (MM/DD) for now
      return .monthDayYear(separator: Character(separator))
    }

    return nil
  }

  private static func commonFormats() -> [Format] {
    [
      .yearMonthDay(separator: "-"),
      .yearMonthDay(separator: "/"),
      .monthDayYear(separator: "/"),
      .monthDayYear(separator: "-"),
      .dayMonthYear(separator: "/"),
      .dayMonthYear(separator: "-"),
    ]
  }
}
