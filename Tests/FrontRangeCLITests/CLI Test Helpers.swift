//
//  captureStandardOutput.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation

/// Creates a temporary file with the specified content and returns its URL.
func createTempFile(withContent content: String) throws -> URL {
  let tempDirectory = FileManager.default.temporaryDirectory
  let tempFileURL = tempDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("txt")
  
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
