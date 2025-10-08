//
//  File.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-07.
//

import Foundation
import IssueReporting

/// A debug print function that includes file, function, and line number information.
///
/// It only prints when compiled in DEBUG mode. If `whileTesting` is false (the default),
/// it will not print when running tests.
/// - Parameters:
///   - items: The items to print.
///   - whileTesting: Whether to print while running tests. Default is false.
///   - separator: The string to insert between each item. Default is a single space.
///   - terminator: The string to append after the last item. Default is a newline.
///   - file: The file name from which the function is called. Default is the current file.
///   - function: The function name from which the function is called. Default is the current function.
///   - line: The line number from which the function is called. Default is the current line
public func printIfDebug(
  _ items: Any...,
  whileTesting: Bool = false,
  separator: String = " ",
  terminator: String = "\n",
  file: String = #file,
  function: String = #function,
  line: Int = #line
) {
  #if DEBUG
  if IssueReporting.isTesting && !whileTesting {
    return
  } else {
    print("DEBUG: [\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)] ", terminator: "")
    print(items.map { "\($0)" }.joined(separator: separator), terminator: terminator)
  }
  #else
  return
  #endif
}
