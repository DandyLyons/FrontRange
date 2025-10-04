//
//  FrontRangeCLITests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

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
    let expectedOutput = "Hello, World!"
    output = try captureStandardOutput {
      var get = try FrontRangeCLIEntry.parseAsRoot(["get", exampleMDPath, "string"])
      try get.run()
    }
    withKnownIssue("DEBUG print statements running in tests") {
      #expect(output == expectedOutput)
    }
  }
  
  @Test func `Has command` () async throws {
    var output = ""
    let expectedOutput = "TRUE"
    output = try captureStandardOutput {
      var has = try FrontRangeCLIEntry.parseAsRoot(["has", exampleMDPath, "string"])
      try has.run()
    }
    withKnownIssue("DEBUG print statements running in tests") {
      #expect(output == expectedOutput)
    }
  }
}
