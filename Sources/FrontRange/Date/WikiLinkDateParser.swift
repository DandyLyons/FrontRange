//
//  WikiLinkDateParser.swift
//  FrontRange
//
//  Created by Claude Code on 2026-01-01.
//

import Foundation

/// Parser for wiki-link style date references like [[2026-01-01]]
public struct WikiLinkDateParser {

  // MARK: - Public API

  /// Parse a wiki link date from a string
  /// Extracts the date portion from [[YYYY-MM-DD]] syntax and parses it
  /// - Parameter string: The wiki link string (e.g., "[[2026-01-01]]")
  /// - Returns: A Date if parsing succeeds, nil otherwise
  public static func parseWikiLinkDate(_ string: String) -> Date? {
    guard let extracted = extractDateFromWikiLink(string) else {
      return nil
    }

    return DateParser.parse(extracted, format: .yearMonthDay(separator: "-"))
  }

  /// Find all wiki link dates in a string
  /// - Parameter string: The string to search
  /// - Returns: Array of extracted date strings (without the brackets)
  public static func findWikiLinkDates(in string: String) -> [String] {
    var dates: [String] = []

    let pattern = #"\[\[(\d{4}-\d{2}-\d{2})\]\]"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return dates
    }

    let range = NSRange(string.startIndex..., in: string)
    let matches = regex.matches(in: string, range: range)

    for match in matches {
      if match.numberOfRanges >= 2,
         let dateRange = Range(match.range(at: 1), in: string) {
        dates.append(String(string[dateRange]))
      }
    }

    return dates
  }

  /// Check if a string contains any wiki link dates
  /// - Parameter string: The string to check
  /// - Returns: True if the string contains at least one wiki link date
  public static func containsWikiLinkDate(_ string: String) -> Bool {
    let pattern = #"\[\[(\d{4}-\d{2}-\d{2})\]\]"#
    return string.range(of: pattern, options: .regularExpression) != nil
  }

  // MARK: - Private Helpers

  private static func extractDateFromWikiLink(_ string: String) -> String? {
    let pattern = #"^\[\[(\d{4}-\d{2}-\d{2})\]\]$"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return nil
    }

    let range = NSRange(string.startIndex..., in: string)
    guard let match = regex.firstMatch(in: string, range: range),
          match.numberOfRanges >= 2 else {
      return nil
    }

    if let dateRange = Range(match.range(at: 1), in: string) {
      return String(string[dateRange])
    }

    return nil
  }
}
