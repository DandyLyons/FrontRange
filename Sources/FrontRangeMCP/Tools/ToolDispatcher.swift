//
//  ToolDispatcher.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import MCP

func runTool(
  withName name: ThisServer.ToolNames,
  params: CallTool.Parameters
) async throws -> CallTool.Result {
  switch name {
    case .get:
      return try await runGetTool(params: params)

    case .set:
      return try await runSetTool(params: params)

    case .has:
      return try await runHasTool(params: params)

    case .list:
      return try await runListTool(params: params)

    case .rename:
      return try await runRenameTool(params: params)

    case .remove:
      return try await runRemoveTool(params: params)

    case .sort_keys:
      return try await runSortKeysTool(params: params)

    case .lines:
      return try await runLinesTool(params: params)

    case .dump:
      return try await runDumpTool(params: params)
  }
}
