//
//  GlobalOptions.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation

struct GlobalOptions: ParsableArguments {
  @Option(name: [.short, .long], help: "Output format")
  var format: OutputFormat = .json
  
  @Argument(help: "Path to the file")
  var file: String
}
