//
//  ReplaceTool.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-11.
//

import Foundation
import FrontRange
import MCP
import Yams

func runReplaceTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  // Extract parameters
  guard let path = params.arguments?["path"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: path")
  }

  guard let data = params.arguments?["data"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: data")
  }

  let formatString = params.arguments?["format"]?.stringValue ?? "json"
  guard let format = DataFormat(rawValue: formatString) else {
    return CallTool.Result(
      content: [.text("Invalid format '\(formatString)'. Use: json, yaml, plist")],
      isError: true
    )
  }

  do {
    // Parse the data to a mapping
    let newFrontMatter = try parseToMapping(data, format: format)

    // Read and parse the document
    let content = try String(contentsOfFile: path, encoding: .utf8)
    var doc = try FrontMatteredDoc(parsing: content)

    // Replace front matter
    doc.frontMatter = newFrontMatter

    // Write back
    let updatedContent = try doc.render()
    try updatedContent.write(toFile: path, atomically: true, encoding: .utf8)

    return CallTool.Result(content: [.text("✓ Replaced front matter in \(path)")])
  } catch let error as DataParsingError {
    return CallTool.Result(
      content: [.text("Error: \(error.description)")],
      isError: true
    )
  } catch {
    return CallTool.Result(
      content: [.text("Error: \(error.localizedDescription)")],
      isError: true
    )
  }
}
