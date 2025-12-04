//
//  SortKeysTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runSortKeysTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let paths = params.arguments?["paths"]?.arrayValue?.compactMap({ $0.stringValue }) else {
    throw MCPError.invalidParams("Missing required parameter: paths")
  }
  let reverse = params.arguments?["reverse"]?.boolValue ?? false

  var results: [String] = []
  for path in paths {
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      var doc = try FrontMatteredDoc(parsing: content)
      doc.frontMatter.sort { $0.key < $1.key }
      if reverse {
        doc.frontMatter.reverse()
      }
      let updatedContent = try doc.render()
      try updatedContent.write(toFile: path, atomically: true, encoding: .utf8)
      results.append("✓ Sorted keys in \(path)")
    } catch {
      results.append("✗ Error sorting keys in \(path): \(error.localizedDescription)")
    }
  }

  return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
}
