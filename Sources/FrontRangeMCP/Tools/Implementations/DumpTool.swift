//
//  DumpTool.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import Foundation
import FrontRange
import MCP
import Yams

func runDumpTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }
  let formatString = params.arguments?["format"]?.stringValue ?? "json"
  let format = OutputFormat(rawValue: formatString) ?? .json
  let includeDelimiters = params.arguments?["includeDelimiters"]?.boolValue ?? false

  do {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    let doc = try FrontMatteredDoc(parsing: content)

    // Format entire front matter
    var formatted = try formatNode(.mapping(doc.frontMatter), format: format)

    // Add delimiters if requested for YAML/raw formats
    if includeDelimiters && (format == .yaml || format == .raw) {
      formatted = "---\n\(formatted)---\n"
    }

    return CallTool.Result(content: [.text(formatted)])
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}
