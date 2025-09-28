//
//  FrontRangeCLITests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import Foundation
import Testing
@testable import FrontRangeCLICore

@Suite struct FrontRangeCLITests {
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
}
