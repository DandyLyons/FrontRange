//
//  FrontRangeMCPTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-01.
//

import Foundation
import MCP
import Testing
@testable import FrontRangeMCP

@Suite struct FrontRangeMCPTests {
  @Test func toolDispatcherRouting() async throws {
    // Test that dispatcher routes to correct tool
    let params = makeCallToolParameters(
      name: "get",
      arguments: [
        "key": .string("test"),
        "path": .string("/invalid/path"),
        "format": .string("json")
      ]
    )

    let result = try await runTool(
      withName: .get,
      params: params
    )

    // Should get an error from GetTool (not a routing error)
    #expect(result.isError == true)
    if case .text(let text) = result.content[0] {
      #expect(text.contains("Error"))
    }
  }

  @Test func toolNamesEnumeration() {
    let allNames = ThisServer.ToolNames.allStrings
    #expect(allNames.contains("get"))
    #expect(allNames.contains("set"))
    #expect(allNames.contains("has"))
    #expect(allNames.contains("list"))
    #expect(allNames.contains("rename"))
    #expect(allNames.contains("remove"))
    #expect(allNames.contains("replace"))
    #expect(allNames.contains("sort_keys"))
    #expect(allNames.contains("lines"))
    #expect(allNames.contains("dump"))
  }

  @Test func toolRegistryVerification() {
    // Verify all expected tools are registered
    let toolNames = ThisServer.tools.map { $0.name }

    // Check that all required tools are present
    #expect(toolNames.contains("get"))
    #expect(toolNames.contains("set"))
    #expect(toolNames.contains("has"))
    #expect(toolNames.contains("list"))
    #expect(toolNames.contains("rename"))
    #expect(toolNames.contains("remove"))
    #expect(toolNames.contains("replace"))
    #expect(toolNames.contains("sort_keys"))
    #expect(toolNames.contains("lines"))
    #expect(toolNames.contains("dump"))
  }
}
