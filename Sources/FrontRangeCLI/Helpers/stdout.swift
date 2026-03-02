//
//  helpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import FrontRange
import Yams

func printNodeAsYAML(node: Yams.Node) throws {
  let yamlString = try Yams.serialize(node: node)
  print(yamlString)
}

func printNodeAsJSON(node: Yams.Node) throws {
  let jsonString = try node.toJSON(options: [.prettyPrinted, .sortedKeys])
  print(jsonString)
}

func printNodeAsPlist(node: Yams.Node) throws {
  let plistString = try nodeToPlist(node)
  print(plistString)
}

public func printKeys(_ keys: [String]) {
  print("Keys:")
  print("-----")
  for key in keys {
    print(key)
  }
  print("-----")
}

/// Writes a message to standard error (stderr) in a concurrency-safe way.
///
/// Use this function instead of the standard `print()` when you need to write error messages or diagnostics to stderr,
/// especially in contexts where strict concurrency checking is required (e.g., Swift 6 on Linux).
///
/// Note: Unlike `print()`, this function does **not** automatically append a newline to the output.
/// If you want the output to end with a newline, you must include `\n` at the end of your message.
func printToStderr(_ message: String) {
  FileHandle.standardError.write(Data(message.utf8))
}
