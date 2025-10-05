//
//  File.swift
//  FrontRange
//
//  Created by Daniel Lyons on 2025-10-04.
//

import Foundation

extension [String] {
  func commaSeparated() -> String {
    return self.joined(separator: ", ")
  }
  
  /// Returns a deduplicated array of strings, preserving the original order.
  /// - Returns: A new array with duplicates removed.
  func deduplicated() -> [String] {
    var seen: Set<String> = []
    return self.filter { seen.insert($0).inserted }
  }
  
  /// Finds all file paths in the String array with the specified extensions.
  ///
  /// Given a list of paths (files or directories), this function searches for the given files,
  /// filtering out any files that do not match the specified extensions.
  ///
  /// - Parameters:
  ///   - paths: An array of file or directory paths to search.
  ///   - extensions: A comma-separated string of file extensions to filter by (e.g., "md,markdown").
  ///   - recursively: A boolean indicating whether to search directories recursively.
  func allFilePaths(
    withExtensions extensions: String,
    recursively: Bool,
  ) -> [String] {
    let fileManager = FileManager.default
    let exts = extensions
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    
    var foundFiles: [String] = []
    
    for path in self.deduplicated() {
      var isDir: ObjCBool = false
      if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
        if isDir.boolValue {
          // It's a directory, search inside it
          let enumerator = fileManager.enumerator(atPath: path)
          while let element = enumerator?.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(element)
            var isSubDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isSubDir) {
              if !isSubDir.boolValue {
                // It's a file, check extension
                let fileExt = (fullPath as NSString).pathExtension.lowercased()
                if exts.contains(fileExt) {
                  foundFiles.append(fullPath)
                }
              } else if !recursively {
                // If not searching recursively, skip subdirectories
                enumerator?.skipDescendants()
              }
            }
          }
        } else {
          // It's a file, check extension
          let fileExt = (path as NSString).pathExtension.lowercased()
          if exts.contains(fileExt) {
            foundFiles.append(path)
          }
        }
      }
    }
    
    return foundFiles
  }
}
