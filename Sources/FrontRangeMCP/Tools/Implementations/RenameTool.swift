//
//  RenameTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runRenameTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let key = params.arguments?["key"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: key")
  }
  guard let newKey = params.arguments?["newKey"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: newKey")
  }
  guard let paths = params.arguments?["paths"]?.arrayValue?.compactMap({ $0.stringValue }) else {
    throw MCPError.invalidParams("Missing required parameter: paths")
  }

  var results: [String] = []
  for path in paths {
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      var doc = try FrontMatteredDoc(parsing: content)
      try doc.renameKey(from: key, to: newKey)
      let updatedContent = try doc.render()
      try updatedContent.write(toFile: path, atomically: true, encoding: .utf8)
      results.append("✓ Renamed key in \(path)")
    } catch {
      results.append("✗ Error renaming key in \(path): \(error.localizedDescription)")
    }
  }

  return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
}
