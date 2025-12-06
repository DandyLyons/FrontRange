//
//  TestHelpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-12-04.
//

import Foundation
import MCP

/// Creates a temporary file with the specified content and returns its path.
func createTempFile(withContent content: String) throws -> String {
  let tempDirectory = FileManager.default.temporaryDirectory
  let tempFileURL = tempDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension("md")

  try content.write(to: tempFileURL, atomically: true, encoding: .utf8)

  return tempFileURL.path
}

/// Copies a file to a temporary location and returns the path of the copied file.
func copyIntoTempFile(source sourceFilePath: String) throws -> String {
  let sourceURL = URL(fileURLWithPath: sourceFilePath)
  let tempDirectory = FileManager.default.temporaryDirectory
  let tempFileURL = tempDirectory
    .appendingPathComponent(UUID().uuidString)
    .appendingPathExtension(sourceURL.pathExtension)

  try FileManager.default.copyItem(at: sourceURL, to: tempFileURL)

  return tempFileURL.path
}

/// Helper to create CallTool.Parameters for testing
func makeCallToolParameters(
  name: String,
  arguments: [String: Value]
) -> CallTool.Parameters {
  return CallTool.Parameters(name: name, arguments: arguments)
}

/// Sample document content for testing
let sampleDocumentContent = """
---
title: Test Document
author: Test Author
tags:
  - test
  - sample
count: 42
active: true
---
# Test Document

This is a test document.
"""
