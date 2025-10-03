//
//  File.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/20/25.
//

import CustomDump
import Foundation
import IssueReporting
import Testing
import FrontRange

@Suite struct YAMLKeysParserTests {
  let parser = YAMLKeysParser()
  let simpleYAML = """
key1: value1
key2: value2
key3: value3
"""
  
  
  @Test
  func `Parse simple keys`() async throws {
   
    var input = Substring(simpleYAML)
    let output = try parser.parse(&input)
    let expected = ["key1", "key2", "key3"]
    
    #expect(output == expected)
    #expect(input.isEmpty)
  }
  
  @Test
  func `Parse keys with comments and nested keys`() async throws {
    let yamlWithComments = """
# This is a comment
key1: value1
  nestedKey1: nestedValue1
key2: value2
# Another comment
key3: value3
"""
    var input = Substring(yamlWithComments)
    let output = try parser.parse(&input)
    let expected = ["key1", "key2", "key3"]
    
    #expect(output == expected)
    #expect(input.isEmpty)
  }
  
  @Test
  func `Parse keys with various value types`() async throws {
    let yamlWithVariousValues = """
intKey: 42
stringKey: Hello, World!
arrayKey:
  - item1
  - item2
nestedKey: 
  subKey1: subValue1
  subKey2: subValue2
"""
    var input = Substring(yamlWithVariousValues)
    let output = try parser.parse(&input)
    let expected = ["intKey", "stringKey", "arrayKey", "nestedKey"]
    #expect(output == expected)
    #expect(input.isEmpty)
  }
  
  @Test
  func `Parse empty input`() async throws {
    var input = Substring("")
    let output = try parser.parse(&input)
    let expected: [String] = []
    
    #expect(output == expected)
    #expect(input.isEmpty)
  }	
}
