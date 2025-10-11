//
//  main.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import Foundation
import FrontRangeCLICore

let args = Array(CommandLine.arguments.dropFirst())
// the first argument is the executable name, so we drop it

// Parse the command line arguments and run the appropriate command
// Uses ArgumentParser's `ParsableCommand` protocol to parse the command line input
FrontRangeCLIEntry.main(args)
