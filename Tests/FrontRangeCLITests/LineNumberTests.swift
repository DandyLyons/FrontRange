//
//  LineNumberTests.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-28.
//

import CustomDump
import Foundation
import FrontRange
import Testing

let string = """
    # Example Document
    Line 2
    Line 3
    ## Section 1
    Line 5
    Line 6
    
    Line After Empty Line
    """

@Suite("Line Number Tests") struct LineNumberTests {
  let line1 = string.substring(lines: 1...1)!
  let line2And3 = string.substring(lines: 2...3)!
  let line4 = string.substring(lines: 4...4)!
  let emptyLine = string.substring(lines: 7...7)!
  
  @Test func `Line Numbering Single Line`() throws {
    let numberedLines = try [NumberedLine](parsing: line1)
    let expected = [
      NumberedLine(number: 1, content: "# Example Document"),
    ]
    expectNoDifference(expected, numberedLines)
    
    let numberedLines4 = try [NumberedLine](parsing: line4)
    let expected4 = [
      NumberedLine(number: 4, content: "## Section 1"),
    ]
    expectNoDifference(expected4, numberedLines4)
  }
  
  @Test func `Line Numbering Multiple Lines`() throws {
    let numberedLines = try [NumberedLine](parsing: line2And3)
    let expected = [
      NumberedLine(number: 2, content: "Line 2"),
      NumberedLine(number: 3, content: "Line 3"),
    ]
    expectNoDifference(expected, numberedLines)
  }
  
  @Test func `Line Numbering Full String`() throws {
    let numberedLines = try [NumberedLine](parsing: string)
    let expected = [
      NumberedLine(number: 1, content: "# Example Document"),
      NumberedLine(number: 2, content: "Line 2"),
      NumberedLine(number: 3, content: "Line 3"),
      NumberedLine(number: 4, content: "## Section 1"),
      NumberedLine(number: 5, content: "Line 5"),
      NumberedLine(number: 6, content: "Line 6"),
      NumberedLine(number: 7, content: ""),
      NumberedLine(number: 8, content: "Line After Empty Line"),
    ]
    expectNoDifference(expected, numberedLines)
  }
  
  @Test func `Line Numbering Empty String`() throws {
    let numberedLines = try [NumberedLine](parsing: "")
    let expected: [NumberedLine] = [
      NumberedLine(number: 1, content: ""),
    ]
    expectNoDifference(expected, numberedLines)
    
    // Empty line from original string
    let numberedLinesEmptyLine = try [NumberedLine](parsing: emptyLine)
    let expectedEmptyLine: [NumberedLine] = [
      NumberedLine(number: 7, content: ""), // Empty lines still retain their line number.
    ]
    expectNoDifference(expectedEmptyLine, numberedLinesEmptyLine)
  }
  
  @Test func `Line Numbering Single Newline`() throws {
    let numberedLines = try [NumberedLine](parsing: "\n")
    let expected = [
      NumberedLine(number: 1, content: ""),
      NumberedLine(number: 2, content: ""),
    ]
    expectNoDifference(expected, numberedLines)
  }
  
  @Test func `NumberedLine Array Starting At`() throws {
    let numberedLines = [NumberedLine](lines: ["Line A", "Line B", "Line C"], startingAt: 5)
    let expected = [
      NumberedLine(number: 5, content: "Line A"),
      NumberedLine(number: 6, content: "Line B"),
      NumberedLine(number: 7, content: "Line C"),
    ]
    expectNoDifference(expected, numberedLines)
  }
}
