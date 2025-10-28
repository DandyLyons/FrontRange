//
//  NumberedLine.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-14.
//

import Foundation
import Parsing

public struct NumberedLine: Equatable {
  public let number: Int
  public let content: String
  public init(number: Int, content: String) {
    self.number = number
    self.content = content
  }
}

extension [NumberedLine] {
  public init(lines: [Substring], startingAt start: Int = 1) {
    self = lines.enumerated()
      .map { index, line in
        NumberedLine(number: index + start, content: String(line))
      }
  }
  
  public init(parsing input: Substring) throws {
    let lines = try LinesParser().parse(input)
    self.init(lines: lines, startingAt: input.startingLineNumber)
  }
  
  public init(parsing input: String) throws {
    try self.init(parsing: Substring(input))
  }
}


public struct LinesParser: Parsing.Parser {
  public typealias Input = Substring
  public typealias Output = [Substring]
  
  public var body: some Parsing.Parser<Substring, [Substring]> {
    Many {
      Prefix(while: { $0 != "\n" }) // Consume all the characters until a newline
    } separator: {
      "\n"
    }
  }
}
