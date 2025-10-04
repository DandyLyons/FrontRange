//
//  captureStandardOutput.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation

/// Helper function to capture standard output during a block of code execution.
func captureStandardOutput(
  from block: () throws -> Void,
) rethrows -> String {
  let pipe = Pipe()
  let originalStdout = dup(STDOUT_FILENO)
  
  dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
  
  try block()
  
  fflush(stdout)
  dup2(originalStdout, STDOUT_FILENO)
  close(originalStdout)
  
  try? pipe.fileHandleForWriting.close() // You must close the connection or it will be stuck in an infinite wait state.
  
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(data: data, encoding: .utf8) ?? ""
}
