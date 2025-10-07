//
//  GlobalOptions.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import PathKit

struct GlobalOptions: ParsableArguments {
  @Option(name: [.short, .long], help: "Output format")
  var format: OutputFormat = .json
  
  @Flag(name: [.short, .long])
  var recursive: Bool = false
  
  /// acceptable file extensions for processing
  @Option(
    name: [.short, .long],
    help: "File extensions to process (comma-separated, no spaces)"
  )
  var extensions: String = "md,markdown,yml,yaml"
  
  @Argument(help: "Path(s) to the file(s)/directory(ies) to process")
  var paths: [Path]
}

