//
//  main.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-01.
//

import Foundation
import MCP

let server = MCP.Server(
  name: "FrontRangeMCP",
  version: "0.0.1",
  instructions: nil,
  capabilities: .init(tools: .init(listChanged: false)),
  configuration: .default
)

let transport = MCP.StdioTransport()
try await server.start(transport: transport)
