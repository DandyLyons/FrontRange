//
//  FrontRangeCLITests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import Command
import CustomDump
import Foundation
import Testing

@Suite(.serialized) struct FrontRangeCLITests {
  let exampleMDPath = Bundle.module
    .url(forResource: "Example", withExtension: "md", subdirectory: "ExampleFiles")!
    .path()
  
  let commandRunner = CommandRunner(logger: nil)
  let cliPath = "\(#filePath)/../../../.build/debug/fr"
  
  @Test func `CLI runs without arguments` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath],
    ).concatenatedString()
    
    let expected = """
    OVERVIEW: A utility for managing front matter in text files.

    USAGE: fr <subcommand>

    OPTIONS:
      --version               Show the version.
      -h, --help              Show help information.

    SUBCOMMANDS:
      get                     Get a value from frontmatter by providing its key
      set                     Set a value in frontmatter
      has                     Check if a key exists in frontmatter
      list, ls                List all keys in frontmatter
      rename, rn              Rename a key from frontmatter
      remove, rm              Remove a key from frontmatter
      replace, r              Replace entire front matter with new data
      search                  Search for files matching a JMESPath query
      sort-keys, sk           Sort keys in frontmatter
      lines                   Extract a range of lines from a file
      dump, d                 Dump entire front matter in specified format
      array-contains          Find files where an array contains a specific value

      See 'fr help <subcommand>' for detailed help.

    """
    
    expectNoDifference(output, expected)
  }
  
  @Test func `Get command` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "get", exampleMDPath, "--key", "string"],
    ).concatenatedString()
    let expectedOutput = "Hello, World!\n"
    expectNoDifference(output, expectedOutput)
  }
  
  @Test func `Has command` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "has", exampleMDPath, "--key", "string"],
    ).concatenatedString()
    
    let expectedOutput = """
      Files containing key 'string':
      \(exampleMDPath)
      
      Files NOT containing key 'string':
      None
      
      """
    expectNoDifference(expectedOutput, output)
  }
  
  @Test func `List command` () async throws {
    let output = try await commandRunner.run(
      arguments: [cliPath, "list", exampleMDPath, "--format", "yaml"],
    ).concatenatedString()
    let expectedOutput = """
    - bool
    - int
    - float
    - string
    - list
    - dict
    """
    expectNoDifference(output.trimmingCharacters(in: .whitespacesAndNewlines), expectedOutput)
  }
  
  @Test func `Remove command` () async throws {
    let tempFilePath = try copyIntoTempFile(source: exampleMDPath).path()
    let output = try await commandRunner.run(
      arguments: [cliPath, "remove", tempFilePath, "--key", "string"],
    ).concatenatedString()
    #expect(output == "")
    let updatedContent = try String(contentsOf: URL(fileURLWithPath: tempFilePath))
    #expect(!updatedContent.contains("string: Hello, World!"))
    try FileManager.default.removeItem(atPath: tempFilePath)
  }
  
  @Test func `Rename command` () async throws {
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    let output = try await commandRunner.run(
      arguments: [cliPath, "rename", tempFileURL.path(), "--key", "string", "--new-key", "newString"],
    ).concatenatedString()
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
  
  @Test func `Set command` () async throws {
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    let output = try await commandRunner.run(
      arguments: [cliPath, "set", tempFileURL.path(), "--key", "string", "--value", "New Value"],
    ).concatenatedString()
    
    #expect(output == "")
    let updatedContent = try String(contentsOf: tempFileURL)
    #expect(updatedContent.contains("string: New Value"))
    
    try FileManager.default.removeItem(at: tempFileURL)
  }
  
  @Test func `SortKeys command` () async throws {
    let tempFileURL = try copyIntoTempFile(source: exampleMDPath)
    let output = try await commandRunner.run(
      arguments: [cliPath, "sort-keys", tempFileURL.path()],
    ).concatenatedString()
    
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
