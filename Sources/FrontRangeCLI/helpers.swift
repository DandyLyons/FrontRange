//
//  helpers.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import Foundation
import FrontRange

// These would be implemented to handle the actual FrontRange operations and formatting

private func outputValue(_ value: Any?, format: OutputFormat) {
  // TODO: Format and output the value based on the specified format
}

private func outputBoolean(_ value: Bool, format: OutputFormat) {
  // TODO: Format and output the boolean based on the specified format
}

private func outputKeys(_ keys: [String], format: OutputFormat) {
  // TODO: Format and output the keys based on the specified format
}

private func serializeDoc(_ doc: FrontMatteredDoc) -> String {
  // TODO: Serialize the FrontMatteredDoc back to a string
  // This would use YamsParser.print to serialize the frontMatter
  // and combine it with the body
  return ""
}
