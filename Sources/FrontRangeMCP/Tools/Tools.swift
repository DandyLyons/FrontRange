//
//  Tools.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import MCP

extension ThisServer {
  enum ToolNames: String, CaseIterable {
    /// All tool names as strings.
    static var allStrings: [String] {
      ToolNames.allCases.map { $0.rawValue }
    }

    case get
    case set
    case has
    case list
    case rename
    case remove
    case replace
    case sort_keys
    case lines
    case dump
  }

  static let tools: [Tool] = [
    Tool(
      name: .get,
      description: "Get a value from frontmatter by providing its key and file path. Returns the value in the specified format (json, yaml, or plainString).",
      params: [
        "key": .object(["type": .string("string"), "description": .string("The key to get from frontmatter")]),
        "path": .object(["type": .string("string"), "description": .string("Path to the file to process")]),
        "format": .object(["type": .string("string"), "description": .string("Output format: json (default), yaml, or plainString")]),
      ],
    ),
    Tool(
      name: .set,
      description: "Set a value in frontmatter. This modifies the file in place.",
      params: [
        "key": .object(["type": .string("string"), "description": .string("The key to set")]),
        "value": .object(["type": .string("string"), "description": .string("The value to set (as a string)")]),
        "paths": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of file paths to process")]),
      ],
    ),
    Tool(
      name: .has,
      description: "Check if a key exists in frontmatter across one or more files. Returns which files contain the key and which don't.",
      params: [
        "key": .object(["type": .string("string"), "description": .string("The key to check for")]),
        "paths": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of file paths to process")]),
      ],
    ),
    Tool(
      name: .list,
      description: "List all keys in frontmatter for a single file. Returns keys in the specified format.",
      params: [
        "path": .object(["type": .string("string"), "description": .string("Path to the file to process")]),
        "format": .object(["type": .string("string"), "description": .string("Output format: json (default), yaml, or plainString")]),
      ],
    ),
    Tool(
      name: .rename,
      description: "Rename a key in frontmatter. This modifies the file(s) in place.",
      params: [
        "key": .object(["type": .string("string"), "description": .string("The key to rename")]),
        "newKey": .object(["type": .string("string"), "description": .string("The new key name")]),
        "paths": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of file paths to process")]),
      ],
    ),
    Tool(
      name: .remove,
      description: "Remove a key from frontmatter. This modifies the file(s) in place.",
      params: [
        "key": .object(["type": .string("string"), "description": .string("The key to remove")]),
        "paths": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of file paths to process")]),
      ],
    ),
    Tool(
      name: .sort_keys,
      description: "Sort keys in frontmatter alphabetically. This modifies the file(s) in place.",
      params: [
        "paths": .object(["type": .string("array"), "items": .object(["type": .string("string")]), "description": .string("Array of file paths to process")]),
        "reverse": .object(["type": .string("boolean"), "description": .string("Reverse the sorting order (default: false)")]),
      ],
    ),
    Tool(
      name: .lines,
      description: "Extract a range of lines from a file.",
      params: [
        "path": .object(["type": .string("string"), "description": .string("Path to the file to read")]),
        "start": .object(["type": .string("integer"), "description": .string("Starting line number (1-indexed)")]),
        "end": .object(["type": .string("integer"), "description": .string("Ending line number (1-indexed, inclusive)")]),
        "numbered": .object(["type": .string("boolean"), "description": .string("Show line numbers in output (default: false)")]),
      ],
    ),
    Tool(
      name: .replace,
      description: "Replace entire front matter with new structured data. Accepts JSON, YAML, or plist format.",
      params: [
        "path": .object(["type": .string("string"), "description": .string("Path to the file to modify")]),
        "data": .object(["type": .string("string"), "description": .string("New front matter data as a string")]),
        "format": .object(["type": .string("string"), "description": .string("Data format: json (default), yaml, or plist")]),
      ],
    ),
    Tool(
      name: .dump,
      description: "Dump entire front matter in specified format (json, yaml, raw, plist). Returns the complete front matter content.",
      params: [
        "path": .object(["type": .string("string"), "description": .string("Path to the file to process")]),
        "format": .object(["type": .string("string"), "description": .string("Output format: json (default), yaml, raw, or plist")]),
        "includeDelimiters": .object(["type": .string("boolean"), "description": .string("Include --- delimiters for YAML/raw output (default: false)")]),
      ],
    ),
  ]
}
