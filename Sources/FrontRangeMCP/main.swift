//
//  main.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-01.
//

import Foundation
import MCP

/// A simple MCP server that implements a "hello_world" tool.
///
/// ## Development
/// To run this MCP server for development, you should use the [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector).
/// To run the MCP Inspector, use the following command:
/// ```bash
/// # Start the FrontRange MCP Server
/// swift run frontrange-mcp
///
/// # Start the MCP Inspector
/// npx @modelcontextprotocol/inspector /Users/daniellyons/Developer/MySwiftPackages/FrontRange/.build/arm64-apple-macosx/debug/frontrange-mcp run
/// ```
let server = MCP.Server(
  name: "FrontRangeMCP",
  version: "0.0.1",
  instructions: nil,
  capabilities: .init(tools: .init(listChanged: false)),
  configuration: .default
)

let tool = Tool(
  name: "hello_world",
  description: "A simple tool that returns a greeting message.",
  inputSchema: .object([
    "type": .string("object")
  ])
)

await server.withMethodHandler(ListTools.self) { params in
  ListTools.Result(tools: [tool])
}

await server.withMethodHandler(CallTool.self) { params in
  guard params.name == tool.name else {
    throw MCPError.invalidParams("Wrong tool name: \(params.name)")
  }
  return CallTool.Result(content: [.text("Hello, World! I am a funky monkey.")])
}

let transport = MCP.StdioTransport()
try await server.start(transport: transport)

await server.waitUntilCompleted()
