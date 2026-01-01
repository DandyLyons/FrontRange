//
//  FrontRangeCLICore.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/26/25.
//

import ArgumentParser
import Foundation

/// The main entry point for the FrontRange CLI application.
@main
public struct FrontRangeCLIEntry: ParsableCommand {
  public init() {}
  public static let configuration = CommandConfiguration(
    commandName: "fr",
    abstract: "A utility for managing front matter in text files.",
    version: "0.2.0-beta",
    subcommands: [Get.self, Set.self, Has.self, List.self, Rename.self, Remove.self, Replace.self, Search.self, SortKeys.self, Lines.self, Dump.self, Validate.self],
    helpNames: [.long, .short]
  )
  
  /// The main entry point for the CLI application.
  ///
  /// To call this CLI in the terminal for debugging, use: `swift run fr` from the package root.
  public mutating func run() throws {
    print(Self.helpMessage())
  }
}
