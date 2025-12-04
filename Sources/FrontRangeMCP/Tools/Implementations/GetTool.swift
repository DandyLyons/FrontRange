//
//  GetTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runGetTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let key = params.arguments?["key"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: key")
  }
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }
  let formatString = params.arguments?["format"]?.stringValue ?? "json"
  let format = OutputFormat(rawValue: formatString) ?? .json

  do {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    guard let value = doc.getValue(forKey: key) else {
      return CallTool.Result(
        content: [.text("Key '\(key)' not found in frontmatter.")],
        isError: true
      )
    }

    let formatted = try formatNode(value, format: format)
    return CallTool.Result(content: [.text(formatted)])
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}
