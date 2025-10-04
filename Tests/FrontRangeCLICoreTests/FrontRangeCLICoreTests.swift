//
//  FrontRangeCLITests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import CustomDump
import Foundation
import Testing
@testable import FrontRangeCLICore

@Suite(.serialized) struct FrontRangeCLITests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md")!
    .path()
  
  @Test func `CLI runs without arguments` () async throws {
    var cli = FrontRangeCLIEntry()
    try cli.run()
  }
  
  @Test func `CLI shows help with --help` () async throws {
    try FrontRangeCLIEntry.parseAsRoot(["--help"])
    #expect(throws: (any Error).self) {
      try FrontRangeCLIEntry.parseAsRoot(["--hello"])
    }
  }
  
  @Test func `Get command` () async throws {
    var output = ""
    let expectedOutput = "Hello, World!\n"
    output = try captureStandardOutput {
      var get = try FrontRangeCLIEntry.parseAsRoot(["get", exampleMDPath, "string"])
      try get.run()
    }
    #expect(output == expectedOutput)
  }
  
  @Test func `Has command` () throws {
    var output = ""
    let expectedOutput = "true\n"
    output = try captureStandardOutput {
      var has = try FrontRangeCLIEntry.parseAsRoot(["has", exampleMDPath, "string"])
      try has.run()
    }
    #expect(expectedOutput == output)
  }
  
  @Test func `List command` () throws {
    var output = ""
    let expectedOutput = """
    - bool
    - int
    - float
    - string
    - list
    - dict
    """
    output = try captureStandardOutput {
      var list = try FrontRangeCLIEntry.parseAsRoot(["list", exampleMDPath, "--format", "yaml"])
      try list.run()
    }
    expectNoDifference(output.trimmingCharacters(in: .whitespacesAndNewlines), expectedOutput)
  }
  
  @Test func `Remove command` () throws {
    var output = ""
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    
    output = try captureStandardOutput {
      var remove = try FrontRangeCLIEntry.parseAsRoot(["remove", tempFileURL.path(), "string"])
      try remove.run()
    }
    #expect(output == "")
    let updatedContent = try String(contentsOf: tempFileURL)
    #expect(!updatedContent.contains("string: Hello, World!"))
    
    try FileManager.default.removeItem(at: tempFileURL)
  }
  
  @Test func `Rename command` () throws {
    var output = ""
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    
    output = try captureStandardOutput {
      var rename = try FrontRangeCLIEntry.parseAsRoot(["rename", tempFileURL.path(), "string", "newString"])
      try rename.run()
    }
    #expect(output == "")
    let updatedContent = try String(contentsOf: tempFileURL)
    let expectedFrontMatter = """
      ---
      bool: true
      int: 42
      float: 3.14
      list:
      - item1
      - item2
      - item3
      dict:
        key1: value1
      newString: "Hello, World!"
      ---
      # Example Markdown File

      ## Example Section
      This is an example markdown file with YAML front matter.
      """
    expectNoDifference(expectedFrontMatter, updatedContent)
    
    try FileManager.default.removeItem(at: tempFileURL)
  }
  
  @Test func `Set command` () throws {
    var output = ""
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    
    output = try captureStandardOutput {
      var set = try FrontRangeCLIEntry.parseAsRoot(["set", tempFileURL.path(), "string", "New Value"])
      try set.run()
    }
    #expect(output == "")
    let updatedContent = try String(contentsOf: tempFileURL)
    #expect(updatedContent.contains("string: New Value"))
    
    try FileManager.default.removeItem(at: tempFileURL)
  }
  
  @Test func `SortKeys command` () throws {
    var output = ""
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    
    output = try captureStandardOutput {
      var sortKeys = try FrontRangeCLIEntry.parseAsRoot(["sort-keys", tempFileURL.path()])
      try sortKeys.run()
    }
    #expect(output == "")
    let updatedContent = try String(contentsOf: tempFileURL)
    let expectedFrontMatter = """
      ---
      bool: true
      dict:
        key1: value1
      float: 3.14
      int: 42
      list:
      - item1
      - item2
      - item3
      string: "Hello, World!"
      ---
      # Example Markdown File

      ## Example Section
      This is an example markdown file with YAML front matter.
      """
    expectNoDifference(expectedFrontMatter, updatedContent)
    try FileManager.default.removeItem(at: tempFileURL)
  }
}
