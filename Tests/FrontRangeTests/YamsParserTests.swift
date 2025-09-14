//
//  YamsParserTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/3/25.
//

import CustomDump
import FrontRange
import IssueReporting
import Testing

#if canImport(AppKit)
import AppKit
#endif

@Suite
struct YamsParserTests {
  let yamlString = """
int: 42
string: Hello, World!
arrayDashes:
  - item1
  - item2
arrayBrackets: [item1, item2]
nested: 
  key1: value1
  key2: value2
"""
  let expectedDict: FrontMatter = [
    "int": 42,
    "string": "Hello, World!",
    "arrayDashes": ["item1", "item2"],
    "arrayBrackets": ["item1", "item2"],
    "nested": ["key1": "value1", "key2": "value2"]
  ]
  
  @Test
  func parseYAMLString() async throws {
    let parser = YamsParser()
    var input = Substring(yamlString)
    let output: FrontMatter = try parser.parse(&input)
    
    #expect(output.count == expectedDict.count)
    #expect(output.keys == expectedDict.keys)
    
    // Use helper function to compare the dictionaries
    #expect(expectedDict.isEqual(to: output))
    
    // Verify input was consumed
    #expect(input.isEmpty)
  }
  
  @Test
  func printDictionary() async throws {
    let parser = YamsParser()
    var input = Substring()
    try parser.print(expectedDict, into: &input)
    
    // Verify we got some YAML output
    #expect(!input.isEmpty)
    
    // Parse the printed YAML back
    var inputCopy = input
    let reparsedOutput = try parser.parse(&inputCopy)
    print(String(inputCopy))
    
    #expect(reparsedOutput.count == expectedDict.count)
    #expect(Set(reparsedOutput.keys) == Set(expectedDict.keys))
    
    // Use helper function to compare the dictionaries
    #expect(reparsedOutput.isEqual(to: expectedDict))
  }
  
  @Test
  func parseAndPrintYAMLString() async throws {
    let parser = YamsParser()
    var originalSubstring = Substring(yamlString)
    let parsedDict = try parser.parse(&originalSubstring)
    
    var printedSubstring = Substring()
    try parser.print(parsedDict, into: &printedSubstring)
    print(String(printedSubstring))
    
    // Parse both dictionaries and compare them
    var originalCopy = Substring(yamlString)
    let originalParsed = try parser.parse(&originalCopy)
    
    var printedCopy = printedSubstring
    let reprintedParsed = try parser.parse(&printedCopy)
    
    #expect(originalParsed.isEqual(to: reprintedParsed))
    
    // Optional: Print diff for debugging (this will show formatting differences)
    print("Original YAML:\n\(yamlString)")
    print("\nReprinted YAML:\n\(printedSubstring)")
    if let diffResult = diff(Substring(yamlString), printedSubstring) {
      print("\nString differences (formatting only):\n\(diffResult)")
    }
  }
  
  @Test
  func parseInvalidYAML() async throws {
    let parser = YamsParser()
    let invalidYaml = "- this is a list, not a dictionary"
    var input = Substring(invalidYaml)
    
    #expect(throws: YamsParser.Error.notADictionary) {
      try parser.parse(&input)
    }
  }
  
  @Test
  func parseEmptyInput() async throws {
    let parser = YamsParser()
    var input = Substring("")
    
    #expect(throws: YamsParser.Error.self) {
      try parser.parse(&input)
    }
  }
  
  @Test
  func yamsParserConfiguration() async throws {
    let parser = YamsParser()
    #expect(parser.encoding == .default)
    #expect(parser.canonical == false)
    #expect(parser.indent == 2)
    #expect(parser.width == 0)
    #expect(parser.allowUnicode == false)
    #expect(parser.lineBreak == .ln)
    #expect(parser.explicitStart == false)
    #expect(parser.explicitEnd == false)
    #expect(parser.version == nil)
    #expect(parser.sortKeys == false)
    #expect(parser.sequenceStyle == .any)
    #expect(parser.mappingStyle == .any)
    #expect(parser.newLineScalarStyle == .any)
    #expect(parser.redundancyAliasingStrategy == nil)
  }
}
