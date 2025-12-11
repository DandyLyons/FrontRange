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
    #expect(allNames.contains("sort_keys"))
    #expect(allNames.contains("lines"))
  }

  @Test func toolRegistryCount() {
    // Verify all tools are registered
    #expect(ThisServer.tools.count == 9) // get, set, has, list, rename, remove, sort_keys, lines, dump
  }
}
