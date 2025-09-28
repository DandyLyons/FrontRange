//
//  YamsParserTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/3/25.
//

import CustomDump
import FrontRange
import IssueReporting
import OrderedCollections
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
  let expectedDict: FrontMatter = {
    let nested: FrontMatter = ["key1": "value1", "key2": "value2"]
    let expected: FrontMatter = [
      "int": 42,
      "string": "Hello, World!",
      "arrayDashes": ["item1", "item2"],
      "arrayBrackets": ["item1", "item2"],
      "nested": nested
    ]
    return expected
  }()
  
  
  
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
    
    #expect(throws: YamsParser.Error.notAMappingNode) {
      try parser.parse(&input)
    }
  }
  
  @Test func `Duplicate Keys`() async throws {
    // TODO: Decide what to do when there are duplicate keys
    #expect(false)
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
  
  @Test("Recursive OrderedDictionary YAML parsing preserves order at all levels")
  func testRecursiveOrderedParsing() throws {
    let yamlString = """
      title: My Blog Post
      author: John Doe
      metadata:
        tags:
          - swift
          - yaml
          - parsing
        published: true
        stats:
          views: 1000
          likes: 50
      content:
        introduction: "Welcome to my blog"
        sections:
          - name: "Introduction"
            content: "This is the intro"
          - name: "Main Content"
            content: "This is the main part"
      date: 2023-12-01
      """
    let parser = YamsParser()
    let result = try parser.parse(yamlString)
    
    // Test that root level keys are in correct order
    let rootKeys = Array(result.keys)
    let expectedRootOrder = ["title", "author", "metadata", "content", "date"]
    #expect(rootKeys == expectedRootOrder, "Root level keys should maintain YAML order")
    
    enum TestError: Error {
      case invalidStructure(String)
    }
    
    // Test that nested dictionary maintains order
    guard let metadata = result["metadata"] as? FrontMatter else {
      throw TestError.invalidStructure("metadata should be OrderedDictionary")
    }
    
    let metadataKeys = Array(metadata.keys)
    let expectedMetadataOrder = ["tags", "published", "stats"]
    #expect(metadataKeys == expectedMetadataOrder, "Metadata keys should maintain YAML order")
    
    // Test deeply nested structure
    guard let stats = metadata["stats"] as? FrontMatter else {
      throw TestError.invalidStructure("stats should be OrderedDictionary")
    }
    
    let statsKeys = Array(stats.keys)
    let expectedStatsOrder = ["views", "likes"]
    #expect(statsKeys == expectedStatsOrder, "Stats keys should maintain YAML order")
    
    // Test values are correct
    #expect(result["title"] as? String == "My Blog Post")
    #expect(result["author"] as? String == "John Doe")
    #expect(metadata["published"] as? Bool == true)
    #expect(stats["views"] as? Int == 1000)
    #expect(stats["likes"] as? Int == 50)
  }
  
  
  @Test("Simple flat YAML maintains key order")
  func testSimpleFlatYAML() throws {
    let yamlString = """
      zebra: last
      alpha: first
      beta: second
      """
    
    let parser = YamsParser()
    let result = try parser.parse(yamlString)
    let keys = Array(result.keys)
    let expectedOrder = ["zebra", "alpha", "beta"]
    
    #expect(keys == expectedOrder, "Keys should maintain original YAML order, not alphabetical")
    #expect(result["zebra"] as? String == "last")
    #expect(result["alpha"] as? String == "first")
    #expect(result["beta"] as? String == "second")
  }
  
  // WIP
  @Test(.disabled())
  func testArraysWithNestedDictionaries() throws {
    let yamlString = """
      items:
        - zebra: animal
          alpha: letter
        - charlie: phonetic
          bravo: nato
      """
    
    let parser = YamsParser()
    let result = try parser.parse(yamlString)
    
    guard let items = result["items"] as? [Any] else {
      throw TestError.invalidStructure("items should be array")
    }
    
    enum TestError: Error {
      case invalidStructure(String)
    }
    
    // Check first item in array
    guard let firstItem = items[0] as? FrontMatter else {
      throw TestError.invalidStructure("first item should be OrderedDictionary")
    }
    
    let firstItemKeys: OrderedSet = firstItem.keys
    #expect(firstItemKeys == OrderedSet(["zebra", "alpha"]), "First item keys should maintain order")
    
    // Check second item in array
    guard let secondItem = items[1] as? FrontMatter else {
      throw TestError.invalidStructure("second item should be OrderedDictionary")
    }
    
    let secondItemKeys = OrderedSet(secondItem.keys)
    #expect(secondItemKeys == OrderedSet(["charlie", "bravo"]), "Second item keys should maintain order")
  }
}
