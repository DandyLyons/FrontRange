//  GlobalOptions.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import PathKit

enum MultiFormat: String, CaseIterable, ExpressibleByArgument {
  case cat
  case json
  case yaml
  case raw
  case plist
  case csv

  var defaultValueDescription: String {
    switch self {
      case .cat: return "cat (default)"
      case .json: return "json"
      case .yaml: return "yaml"
      case .raw: return "raw"
      case .plist: return "plist"
      case .csv: return "csv"
    }
  }
}

struct GlobalOptions: ParsableArguments {
  @Option(name: [.short, .long], help: "Output format")
  var format: OutputFormat = .json

  @Option(name: .long, help: "Format for representing multiple files")
  var multiFormat: MultiFormat = .cat
  
  @Flag(name: [.short, .long])
  var recursive: Bool = false
  
  /// acceptable file extensions for processing
  @Option(
    name: [.short, .long],
    help: "File extensions to process (comma-separated, no spaces)"
  )
  var extensions: String = "md,markdown,yml,yaml"

  // MARK: - Date Filtering Options

  // Modified date filters
  @Option(name: .long, help: "Keep files modified after this date (ISO8601 or YYYY-MM-DD)")
  var modifiedAfter: String?

  @Option(name: .long, help: "Keep files modified before this date (ISO8601 or YYYY-MM-DD)")
  var modifiedBefore: String?

  @Option(name: .long, help: "Keep files modified in this month (YYYY-MM)")
  var modifiedMonth: String?

  // Created date filters
  @Option(name: .long, help: "Keep files created after this date (ISO8601 or YYYY-MM-DD)")
  var createdAfter: String?

  @Option(name: .long, help: "Keep files created before this date (ISO8601 or YYYY-MM-DD)")
  var createdBefore: String?

  @Option(name: .long, help: "Keep files created in this month (YYYY-MM)")
  var createdMonth: String?

  // Added date filters (macOS only)
  @Option(name: .long, help: "Keep files added after this date (ISO8601 or YYYY-MM-DD)")
  var addedAfter: String?

  @Option(name: .long, help: "Keep files added before this date (ISO8601 or YYYY-MM-DD)")
  var addedBefore: String?

  @Option(name: .long, help: "Keep files added in this month (YYYY-MM)")
  var addedMonth: String?

  /// The paths as input by the user (before following the user's input options).
  ///
  /// See `paths` for the processed paths after applying user options like recursion and extension filtering.
  @Argument(help: "Path(s) to the file(s)/directory(ies) to process")
  fileprivate var _paths: [Path]
  
  /// The processed paths after applying user options like recursion and extension filtering.
  ///
  /// This is the raw input from the user, which may include directories. After receiving this input,
  /// we do some additional processing including:
  /// 1. Expanding directories into their child files (shallowly)
  /// 2. Recursively expanding directories if the `--recursive` flag is set
  /// 3. Filtering files by the specified extensions in the `--extensions` option
  ///
  /// This property throws errors if any path operations fail, such as reading directory contents.
  /// It returns a flat array of `Path` objects representing the final set of files to be processed.
  var paths: [Path] {
    get throws { try _calculatePaths() }
  }
  
  fileprivate func _calculatePaths() throws -> [Path] {
    var allPaths: [Path] = []
    
    for path in self._paths {
      if path.isDirectory {
        if self.recursive {
          let recursiveChildren = try path.recursiveChildren()
          allPaths.append(contentsOf: recursiveChildren)
        } else {
          let children = try path.children()
          allPaths.append(contentsOf: children)
        }
        
      } else { // path is a file, not a directory
        allPaths.append(path)
      }
    }
    
    // Filter by extensions if any are specified
    let exts: [String] = self.extensions
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
      .filter { !$0.isEmpty }
    
    if !exts.isEmpty {
      allPaths = allPaths.filter { path in
        guard let fileExt = path.extension?.lowercased() else { return false }
        return exts.contains(fileExt)
      }
    }
    
    // Apply date filtering
    allPaths = try applyDateFilters(to: allPaths)

    return allPaths
  }

  // MARK: - Date Filtering Helpers

  private func applyDateFilters(to paths: [Path]) throws -> [Path] {
    var filtered = paths

    // Apply modified date filters
    if modifiedAfter != nil || modifiedBefore != nil || modifiedMonth != nil {
      filtered = try filtered.filter { path in
        let metadata = try path.metadata()
        let afterDate = try modifiedAfter.map { try parseDateFlag($0, flagName: "--modified-after") }
        let beforeDate = try modifiedBefore.map { try parseDateFlag($0, flagName: "--modified-before") }
        let month = try modifiedMonth.map { try parseMonthFlag($0, flagName: "--modified-month") }
        return metadata.matchesModified(after: afterDate, before: beforeDate, month: month)
      }
    }

    // Apply created date filters
    if createdAfter != nil || createdBefore != nil || createdMonth != nil {
      filtered = try filtered.filter { path in
        let metadata = try path.metadata()
        let afterDate = try createdAfter.map { try parseDateFlag($0, flagName: "--created-after") }
        let beforeDate = try createdBefore.map { try parseDateFlag($0, flagName: "--created-before") }
        let month = try createdMonth.map { try parseMonthFlag($0, flagName: "--created-month") }
        return metadata.matchesCreated(after: afterDate, before: beforeDate, month: month)
      }
    }

    // Apply added date filters
    if addedAfter != nil || addedBefore != nil || addedMonth != nil {
      filtered = try filtered.filter { path in
        let metadata = try path.metadata()
        let afterDate = try addedAfter.map { try parseDateFlag($0, flagName: "--added-after") }
        let beforeDate = try addedBefore.map { try parseDateFlag($0, flagName: "--added-before") }
        let month = try addedMonth.map { try parseMonthFlag($0, flagName: "--added-month") }
        return metadata.matchesAdded(after: afterDate, before: beforeDate, month: month)
      }
    }

    return filtered
  }

  private func parseDateFlag(_ string: String, flagName: String) throws -> Date {
    guard let date = DateParser.parse(string) else {
      throw ValidationError("Invalid date format for \(flagName): '\(string)'. Use ISO8601 or YYYY-MM-DD.")
    }
    return date
  }

  private func parseMonthFlag(_ string: String, flagName: String) throws -> (Int, Int) {
    guard let month = DateRange.parseMonth(string) else {
      throw ValidationError("Invalid month format for \(flagName): '\(string)'. Use YYYY-MM format.")
    }
    return month
  }
}

