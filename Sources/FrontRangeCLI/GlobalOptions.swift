//  GlobalOptions.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/27/25.
//

import ArgumentParser
import Foundation
import PathKit

enum MultiFormat: String, CaseIterable, ExpressibleByArgument {
  case cat
  case json
  case yaml
  case raw
  case plist

  var defaultValueDescription: String {
    switch self {
      case .cat: return "cat (default)"
      case .json: return "json"
      case .yaml: return "yaml"
      case .raw: return "raw"
      case .plist: return "plist"
    }
  }
}

struct GlobalOptions: ParsableArguments {
  @Option(name: [.short, .long], help: "Output format")
  var format: OutputFormat = .json

  @Option(name: .long, help: "Format for representing multiple files")
  var multiFormat: MultiFormat = .cat
  
  @Flag(name: [.short, .long])
  var recursive: Bool = false
  
  /// acceptable file extensions for processing
  @Option(
    name: [.short, .long],
    help: "File extensions to process (comma-separated, no spaces)"
  )
  var extensions: String = "md,markdown,yml,yaml"
  
  /// The paths as input by the user (before following the user's input options).
  ///
  /// See `paths` for the processed paths after applying user options like recursion and extension filtering.
  @Argument(help: "Path(s) to the file(s)/directory(ies) to process")
  fileprivate var _paths: [Path]
  
  /// The processed paths after applying user options like recursion and extension filtering.
  ///
  /// This is the raw input from the user, which may include directories. After receiving this input,
  /// we do some additional processing including:
  /// 1. Expanding directories into their child files (shallowly)
  /// 2. Recursively expanding directories if the `--recursive` flag is set
  /// 3. Filtering files by the specified extensions in the `--extensions` option
  ///
  /// This property throws errors if any path operations fail, such as reading directory contents.
  /// It returns a flat array of `Path` objects representing the final set of files to be processed.
  var paths: [Path] {
    get throws { try _calculatePaths() }
  }
  
  fileprivate func _calculatePaths() throws -> [Path] {
    var allPaths: [Path] = []
    
    for path in self._paths {
      if path.isDirectory {
        if self.recursive {
          let recursiveChildren = try path.recursiveChildren()
          allPaths.append(contentsOf: recursiveChildren)
        } else {
          let children = try path.children()
          allPaths.append(contentsOf: children)
        }
        
      } else { // path is a file, not a directory
        allPaths.append(path)
      }
    }
    
    // Filter by extensions if any are specified
    let exts: [String] = self.extensions
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
      .filter { !$0.isEmpty }
    
    if !exts.isEmpty {
      allPaths = allPaths.filter { path in
        guard let fileExt = path.extension?.lowercased() else { return false }
        return exts.contains(fileExt)
      }
    }
    
    return allPaths
  }
}

