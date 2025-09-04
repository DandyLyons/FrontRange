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
  let expectedDict: [String: Any] = [
    "int": 42,
    "string": "Hello, World!",
    "arrayDashes": ["item1", "item2"],
    "arrayBrackets": ["item1", "item2"],
    "nested": ["key1": "value1", "key2": "value2"]
  ]
  
  // Helper function to compare [String: Any] dictionaries
  func compareDictionaries(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
    guard dict1.count == dict2.count else { return false }
    
    for (key, value1) in dict1 {
      guard let value2 = dict2[key] else { return false }
      
      if !compareAnyValues(value1, value2) {
        return false
      }
    }
    return true
  }
  
  // Helper function to compare Any values recursively
  func compareAnyValues(_ value1: Any, _ value2: Any) -> Bool {
    // Compare integers
    if let int1 = value1 as? Int, let int2 = value2 as? Int {
      return int1 == int2
    }
    
    // Compare strings
    if let str1 = value1 as? String, let str2 = value2 as? String {
      return str1 == str2
    }
    
    // Compare arrays
    if let arr1 = value1 as? [Any], let arr2 = value2 as? [Any] {
      guard arr1.count == arr2.count else { return false }
      for (a1, a2) in zip(arr1, arr2) {
        if !compareAnyValues(a1, a2) { return false }
      }
      return true
    }
    
    // Compare dictionaries recursively
    if let dict1 = value1 as? [String: Any], let dict2 = value2 as? [String: Any] {
      return compareDictionaries(dict1, dict2)
    }

#if canImport(AppKit)
    // For other types, try using NSObject comparison as fallback
    if let obj1 = value1 as? NSObject, let obj2 = value2 as? NSObject {
      return obj1 == obj2
    }
#endif
    
    return false
  }
  
  @Test
  func parseYAMLString() async throws {
    let parser = YamsParser()
    var input = Substring(yamlString)
    let output = try parser.parse(&input)
    
    #expect(output.count == expectedDict.count)
    #expect(Set(output.keys) == Set(expectedDict.keys))
    
    // Use helper function to compare the dictionaries
    #expect(compareDictionaries(output, expectedDict))
    
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
    
    #expect(reparsedOutput.count == expectedDict.count)
    #expect(Set(reparsedOutput.keys) == Set(expectedDict.keys))
    
    // Use helper function to compare the dictionaries
    #expect(compareDictionaries(reparsedOutput, expectedDict))
  }
  
  @Test
  func parseAndPrintYAMLString() async throws {
    let parser = YamsParser()
    var originalSubstring = Substring(yamlString)
    let parsedDict = try parser.parse(&originalSubstring)
    
    var printedSubstring = Substring()
    try parser.print(parsedDict, into: &printedSubstring)
    
    // Instead of comparing strings directly, parse both and compare the dictionaries
    var originalCopy = Substring(yamlString)
    let originalParsed = try parser.parse(&originalCopy)
    
    var printedCopy = printedSubstring
    let reprintedParsed = try parser.parse(&printedCopy)
    
    // Compare the semantic content rather than the string representation
    #expect(compareDictionaries(originalParsed, reprintedParsed))
    
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
}
