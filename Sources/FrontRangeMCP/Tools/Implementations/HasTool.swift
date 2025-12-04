//
//  HasTool.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-11-04.
//

import Foundation
import FrontRange
import MCP

func runHasTool(params: CallTool.Parameters) async throws -> CallTool.Result {
  guard let key = params.arguments?["key"]?.stringValue else {
    throw MCPError.invalidParams("Missing required parameter: key")
  }
  guard let paths = params.arguments?["paths"]?.arrayValue?.compactMap({ $0.stringValue }) else {
    throw MCPError.invalidParams("Missing required parameter: paths")
  }

  var filesWithKey: [String] = []
  var filesWithoutKey: [String] = []

  for path in paths {
    do {
      let content = try String(contentsOfFile: path, encoding: .utf8)
      let doc = try FrontMatteredDoc(parsing: content)
      if doc.hasKey(key) {
        filesWithKey.append(path)
      } else {
        filesWithoutKey.append(path)
      }
    } catch {
      filesWithoutKey.append("\(path) (error: \(error.localizedDescription))")
    }
  }

  let result = """
  Files containing key '\(key)':
  \(filesWithKey.isEmpty ? "None" : filesWithKey.joined(separator: "\n"))

  Files NOT containing key '\(key)':
  \(filesWithoutKey.isEmpty ? "None" : filesWithoutKey.joined(separator: "\n"))
  """

  return CallTool.Result(content: [.text(result)])
}
