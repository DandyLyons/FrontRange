//
//  main.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-01.
//

import Foundation
import MCP

enum ThisServer {}

/// An MCP server that implements multiple tools for front matter management,
/// including: get, set, has, list, rename, remove, sort_keys, and lines.
///
/// ## Development
/// To run this MCP server for development, you should use the [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector).
/// To run the MCP Inspector, use the following command:
/// ```bash
/// # Start the FrontRange MCP Server
/// swift run frontrange-mcp
///
/// # Start the MCP Inspector
/// npx @modelcontextprotocol/inspector <path-to-your-build-artifact>/frontrange-mcp
/// ```
let server = MCP.Server(
  name: "FrontRangeMCP",
  version: "0.2.0-beta",
  instructions: nil,
  capabilities: .init(tools: .init(listChanged: false)),
  configuration: .default
)

await server.withMethodHandler(ListTools.self) { params in
  ListTools.Result(tools: ThisServer.tools)
}

await server.withMethodHandler(CallTool.self) { params in
  if let toolName = ThisServer.ToolNames(rawValue: params.name) {
    try await runTool(withName: toolName, params: params)
  } else {
    throw MCPError.methodNotFound("Tool with name '\(params.name)' not found.")
  }
}

let transport = MCP.StdioTransport()
try await server.start(transport: transport)

await server.waitUntilCompleted()

