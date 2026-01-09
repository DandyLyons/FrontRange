//
//  captureStandardOutput.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation
import FrontRange
import Yams

/// Creates a temporary file with the specified content and returns its URL.
func createTempFile(withContent content: String) throws -> URL {
  let tempDirectory = FileManager.default.temporaryDirectory
  let tempFileURL = tempDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("md")

  try content.write(to: tempFileURL, atomically: true, encoding: .utf8)

  return tempFileURL
}

/// Copies a file to a temporary location and returns the URL of the copied file.
func copyIntoTempFile(
  source sourceFilePath: String,
) throws -> URL {
  let sourceURL = URL(fileURLWithPath: sourceFilePath)
  let tempDirectory = FileManager.default.temporaryDirectory
  let tempFileURL = tempDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension(sourceURL.pathExtension)

  try FileManager.default.copyItem(at: sourceURL, to: tempFileURL)

  return tempFileURL
}

/// Creates a temporary file with specified front matter array
func createTempFileWithArray(key: String, values: [String]) throws -> String {
  let frontMatter = """
    ---
    \(key):
    \(values.map { "  - \($0)" }.joined(separator: "\n"))
    ---
    Test content
    """
  let url = try createTempFile(withContent: frontMatter)
  return url.path
}

/// Reads array values from a front matter key
func extractArrayValues(from doc: FrontMatteredDoc, key: String) throws -> [String] {
  guard let node = doc.getValue(forKey: key),
        case .sequence(let sequence) = node else {
    return []
  }
  return sequence.compactMap { node in
    guard case .scalar(let scalar) = node else { return nil }
    return scalar.string
  }
}
