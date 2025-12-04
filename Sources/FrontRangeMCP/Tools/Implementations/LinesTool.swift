//
//  LinesTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runLinesTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }
  guard let start = params.arguments?["start"]?.intValue else {
    throw MCPError.invalidParams("Missing required parameter: start")
  }
  guard let end = params.arguments?["end"]?.intValue else {
    throw MCPError.invalidParams("Missing required parameter: end")
  }
  let numbered = params.arguments?["numbered"]?.boolValue ?? false

  do {
    guard start > 0 else {
      throw MCPError.invalidParams("Start line must be greater than 0")
    }
    guard end >= start else {
      throw MCPError.invalidParams("End line must be greater than or equal to start line")
    }

    let contents = try String(contentsOfFile: path, encoding: .utf8)
    guard let lines = contents.substring(lines: start...end) else {
      throw MCPError.invalidParams("File does not have enough lines to extract the specified range")
    }

    let result: String
    if numbered {
      result = lines.split(separator: "\n", omittingEmptySubsequences: false)
        .enumerated()
        .map { index, line in
          let lineNumber = start + index
          return "\(lineNumber): \(line)"
        }
        .joined(separator: "\n")
    } else {
      result = String(lines)
    }

    return CallTool.Result(content: [.text(result)])
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}
