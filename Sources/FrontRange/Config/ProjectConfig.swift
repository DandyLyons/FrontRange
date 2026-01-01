//
//  ProjectConfig.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import Yams

/// Project-level configuration loaded from .frontrange.yml
public struct ProjectConfig: Codable, Equatable {
  /// Schema mappings: glob pattern → schema file path
  public let schemas: [String: String]?

  /// Validation settings
  public let validation: ValidationConfig?

  /// Extension preferences
  public let extensions: ExtensionsConfig?

  public init(
    schemas: [String: String]? = nil,
    validation: ValidationConfig? = nil,
    extensions: ExtensionsConfig? = nil
  ) {
    self.schemas = schemas
    self.validation = validation
    self.extensions = extensions
  }

  /// Load project config from .frontrange.yml in the specified directory
  ///
  /// - Parameter projectRoot: Path to project root directory
  /// - Returns: ProjectConfig if file exists and is valid, nil otherwise
  /// - Throws: If file exists but cannot be parsed
  public static func load(from projectRoot: String) throws -> ProjectConfig? {
    let configPath = (projectRoot as NSString).appendingPathComponent(".frontrange.yml")
    let url = URL(fileURLWithPath: configPath)

    // Check if file exists
    guard FileManager.default.fileExists(atPath: configPath) else {
      return nil
    }

    // Read file
    let yamlString = try String(contentsOf: url, encoding: .utf8)

    // Parse YAML
    let decoder = YAMLDecoder()
    return try decoder.decode(ProjectConfig.self, from: yamlString)
  }

  /// Find the schema path for a given file path using glob pattern matching
  ///
  /// Patterns are matched in the order they appear in the config.
  /// First matching pattern wins.
  ///
  /// - Parameter filePath: Absolute file path to match
  /// - Returns: Schema path if a matching pattern is found, nil otherwise
  public func schemaPath(for filePath: String) -> String? {
    guard let schemas = schemas else { return nil }

    // Convert to relative path if possible (for better pattern matching)
    let path = filePath

    // Try each pattern in order
    for (pattern, schemaPath) in schemas {
      if matchesGlobPattern(path: path, pattern: pattern) {
        return schemaPath
      }
    }

    return nil
  }

  // MARK: - Private Helpers

  /// Match a file path against a glob pattern
  ///
  /// Supports:
  /// - `*` matches any sequence of characters (except /)
  /// - `**` matches any sequence of characters (including /)
  /// - `?` matches any single character
  ///
  /// Examples:
  /// - `*.md` matches `file.md` but not `dir/file.md`
  /// - `**/*.md` matches `file.md` and `dir/file.md` and `dir/sub/file.md`
  /// - `posts/*.md` matches `posts/file.md` but not `posts/sub/file.md`
  /// - `posts/**/*.md` matches `posts/file.md` and `posts/sub/file.md`
  private func matchesGlobPattern(path: String, pattern: String) -> Bool {
    // Convert glob pattern to regex
    var regexPattern = "^"

    var i = pattern.startIndex
    while i < pattern.endIndex {
      let c = pattern[i]

      if c == "*" {
        // Check for **
        let nextIndex = pattern.index(after: i)
        if nextIndex < pattern.endIndex && pattern[nextIndex] == "*" {
          // ** matches everything including /
          regexPattern += ".*"
          i = pattern.index(after: nextIndex)
        } else {
          // * matches everything except /
          regexPattern += "[^/]*"
          i = nextIndex
        }
      } else if c == "?" {
        // ? matches any single character
        regexPattern += "."
        i = pattern.index(after: i)
      } else if c == "." {
        // Escape .
        regexPattern += "\\."
        i = pattern.index(after: i)
      } else if "[](){}+|^$\\".contains(c) {
        // Escape special regex characters
        regexPattern += "\\\(c)"
        i = pattern.index(after: i)
      } else {
        regexPattern += String(c)
        i = pattern.index(after: i)
      }
    }

    regexPattern += "$"

    // Try to match with regex
    guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
      return false
    }

    let range = NSRange(path.startIndex..., in: path)
    return regex.firstMatch(in: path, options: [], range: range) != nil
  }
}

/// Validation configuration settings
public struct ValidationConfig: Codable, Equatable {
  /// File patterns to exclude from validation
  public let exclude: [String]?

  /// Whether to cache schemas for performance (default: true)
  public let cacheSchemas: Bool?

  public init(
    exclude: [String]? = nil,
    cacheSchemas: Bool? = nil
  ) {
    self.exclude = exclude
    self.cacheSchemas = cacheSchemas
  }
}

/// Extension preferences
public struct ExtensionsConfig: Codable, Equatable {
  /// Default file extensions to process
  public let `default`: [String]?

  public init(default: [String]? = nil) {
    self.default = `default`
  }
}
