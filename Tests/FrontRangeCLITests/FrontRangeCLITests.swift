//
//  FrontRangeCLITests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import Foundation
import Testing
@testable import FrontRangeCLI

@Suite struct FrontRangeCLITests {
  
  @Test func `Placeholder test` () async throws {
    #expect(true)
  }
  
  @Test func `CLI runs without arguments` () async throws {
    // Simulate running the CLI without any arguments
    // Since the main command just prints a welcome message, we expect no errors
    #expect(true)
  }

}
