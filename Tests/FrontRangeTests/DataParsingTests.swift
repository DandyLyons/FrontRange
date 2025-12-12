//
//  DataParsingTests.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import CustomDump
import Foundation
import Testing
import Yams
@testable import FrontRange

@Suite struct DataParsingTests {
  @Test func `Parse JSON to mapping` () throws {
    let json = """
    {
      "title": "Test",
      "draft": true,
      "count": 42
    }
    """

    let mapping = try parseToMapping(json, format: .json)

    // Verify it's a valid mapping with expected keys
    #expect(mapping[.scalar(.init("title"))] != nil)
    #expect(mapping[.scalar(.init("draft"))] != nil)
    #expect(mapping[.scalar(.init("count"))] != nil)
  }

  @Test func `Parse YAML to mapping` () throws {
    let yaml = """
    title: Test Post
    draft: false
    tags:
      - swift
      - cli
    """

    let mapping = try parseToMapping(yaml, format: .yaml)

    #expect(mapping[.scalar(.init("title"))] != nil)
    #expect(mapping[.scalar(.init("draft"))] != nil)
    #expect(mapping[.scalar(.init("tags"))] != nil)
  }

  @Test func `Parse plist to mapping` () throws {
    let plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>title</key>
      <string>Test</string>
      <key>draft</key>
      <true/>
    </dict>
    </plist>
    """

    let mapping = try parseToMapping(plist, format: .plist)

    #expect(mapping[.scalar(.init("title"))] != nil)
    #expect(mapping[.scalar(.init("draft"))] != nil)
  }

  @Test func `Reject array input from JSON` () throws {
    let jsonArray = """
    ["item1", "item2", "item3"]
    """

    #expect(throws: DataParsingError.self) {
      try parseToMapping(jsonArray, format: .json)
    }
  }

  @Test func `Reject scalar input from JSON` () throws {
    let jsonScalar = """
    "just a string"
    """

    #expect(throws: DataParsingError.self) {
      try parseToMapping(jsonScalar, format: .json)
    }
  }

  @Test func `Invalid JSON throws parse error` () throws {
    let badJSON = "{invalid json"

    #expect(throws: DataParsingError.self) {
      try parseToMapping(badJSON, format: .json)
    }
  }

  @Test func `Invalid YAML throws parse error` () throws {
    let badYAML = """
    ---
    invalid: yaml: structure:
    """

    #expect(throws: DataParsingError.self) {
      try parseToMapping(badYAML, format: .yaml)
    }
  }

  @Test func `Reject YAML array` () throws {
    let yamlArray = """
    - item1
    - item2
    - item3
    """

    #expect(throws: DataParsingError.self) {
      try parseToMapping(yamlArray, format: .yaml)
    }
  }

  @Test func `Reject YAML scalar` () throws {
    let yamlScalar = "just a string"

    #expect(throws: DataParsingError.self) {
      try parseToMapping(yamlScalar, format: .yaml)
    }
  }

  @Test func `Parse nested JSON structures` () throws {
    let json = """
    {
      "metadata": {
        "author": "Jane Doe",
        "category": "Technical"
      },
      "tags": ["swift", "cli"]
    }
    """

    let mapping = try parseToMapping(json, format: .json)

    #expect(mapping[.scalar(.init("metadata"))] != nil)
    #expect(mapping[.scalar(.init("tags"))] != nil)

    // Verify nested structure
    if case .mapping(let metadataMapping) = mapping[.scalar(.init("metadata"))] {
      #expect(metadataMapping[.scalar(.init("author"))] != nil)
      #expect(metadataMapping[.scalar(.init("category"))] != nil)
    } else {
      Issue.record("Expected metadata to be a mapping")
    }
  }

  @Test func `Parse boolean values correctly` () throws {
    let json = """
    {
      "draft": true,
      "published": false
    }
    """

    let mapping = try parseToMapping(json, format: .json)

    // Verify booleans are parsed
    if case .scalar(let draftScalar) = mapping[.scalar(.init("draft"))] {
      #expect(draftScalar.string == "true")
    } else {
      Issue.record("Expected draft to be a scalar")
    }

    if case .scalar(let publishedScalar) = mapping[.scalar(.init("published"))] {
      #expect(publishedScalar.string == "false")
    } else {
      Issue.record("Expected published to be a scalar")
    }
  }

  @Test func `Parse numbers correctly` () throws {
    let json = """
    {
      "count": 42,
      "rating": 4.5
    }
    """

    let mapping = try parseToMapping(json, format: .json)

    #expect(mapping[.scalar(.init("count"))] != nil)
    #expect(mapping[.scalar(.init("rating"))] != nil)
  }
}
