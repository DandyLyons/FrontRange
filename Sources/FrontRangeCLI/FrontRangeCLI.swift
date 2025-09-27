//
//  FrontRangeCLI.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import ArgumentParser
import Foundation

@main
struct FrontRangeCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "fr",
    abstract: "A utility for managing front matter in text files.",
    version: "0.1.0",
    subcommands: [Get.self, Set.self, Has.self, List.self, Remove.self],
    helpNames: [.long, .short]
  )
  
  /// The main entry point for the CLI application.
  ///
  /// To call this CLI in the terminal for debugging, use: `swift run fr` from the package root.
  mutating func run() throws {
    print("Welcome to FrontRange CLI!")
  }
}
