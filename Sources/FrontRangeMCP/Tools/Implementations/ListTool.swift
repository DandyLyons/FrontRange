//
//  ListTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runListTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }
  let formatString = params.arguments?["format"]?.stringValue ?? "json"
  let format = OutputFormat(rawValue: formatString) ?? .json

  do {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    let doc = try FrontMatteredDoc(parsing: content)
    let keys = Array(doc.frontMatter.keys).compactMap { $0.string }
    let formatted = try formatArray(keys, format: format)
    return CallTool.Result(content: [.text(formatted)])
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}
