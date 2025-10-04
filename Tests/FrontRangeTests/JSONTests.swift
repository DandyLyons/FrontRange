//
//  JSONTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import CustomDump
import Foundation
import IssueReporting
import Testing
import Yams
@testable import FrontRange

@Suite struct JSONTests {
  let yamlString = """
    age: 42
    author: Jane Doe
    date: 2023-10-01 00:00:00 +0000
    tags:
    - swift
    - parsing
    - yaml
    title: Sample Document
    """
  let expectedJSONString = """
    {
      "age" : 42,
      "author" : "Jane Doe",
      "date" : "2023-10-01 00:00:00 +0000",
      "tags" : [
        "swift",
        "parsing",
        "yaml"
      ],
      "title" : "Sample Document"
    }
    """
  let jsonOptions: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
  
  @Test func `Yams Node to JSON conversion` () throws {
    guard let node = try? Yams.compose(yaml: yamlString) else {
      reportIssue("Failed to parse YAML string into Yams.Node")
      return
    }
    let jsonString = try node.toJSON(options: jsonOptions)
    expectNoDifference(expectedJSONString, jsonString)
  }
  
  @Test func `YAML string to JSON conversion` () throws {
    let yamlStringConvertedToJSON = try yamlString.yamlToJSON(options: jsonOptions)
    expectNoDifference(expectedJSONString, yamlStringConvertedToJSON)
  }
  
  @Test func `Invalid YAML` () throws {
    let invalidYAML = " : - invalid"
    #expect(throws: YamlError.self) {
      let _ = try invalidYAML
        .yamlToJSON(options: jsonOptions)
    }
    #expect(throws: YamlError.self) {
      let _ = try Yams.compose(yaml: invalidYAML)?
        .toJSON(options: jsonOptions)
    }
  }
  
}
