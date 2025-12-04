//
//  Tool helpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import MCP

// MARK: - Tool Extension Convenience Initializers

// MARK: Without Annotations
extension Tool {
  init(
    name: ThisServer.ToolNames,
    description: String?,
    params: [String: Value],
  ) {
    self.init(
      name: name.rawValue,
      description: description,
      params: params
    )
  }
  
  public init(
    name: String,
    description: String?,
    params: [String: Value],
  ) {
    self.init(
      name: name,
      description: description,
      inputSchema: .object([
        "type": .string("object"),
        "properties": .object(params),
      ])
    )
  }
}

// MARK: With Annotations
extension Tool {
  init(
    name: ThisServer.ToolNames,
    description: String?,
    params: [String: Value],
    annotations: Annotations
  ) {
    self.init(
      name: name.rawValue,
      description: description,
      params: params,
      annotations: annotations
    )
  }
  
  init(
    name: String,
    description: String?,
    params: [String: Value],
    annotations: Annotations
  ) {
    self.init(
      name: name,
      description: description,
      inputSchema: .object([
        "type": .string("object"),
        "properties": .object(params),
      ]),
      annotations: annotations
    )
  }
}
