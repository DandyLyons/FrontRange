//
//  FrontRangeMCPTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-01.
//

import Foundation
import MCP
import Testing

@Suite struct FrontRangeMCPTests {
  @Test func exampleTest() async throws {
    let (client, server) = await MCP.InMemoryTransport.createConnectedPair()
    
    let _ = try await server.connect()
    let _ = await client.disconnect()
  }
}
