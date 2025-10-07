//
//  Path+ArgumentParser.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-07.
//

import ArgumentParser
import Foundation
import Parsing
import PathKit

extension Path: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = Path(argument).absolute()
    }
}
