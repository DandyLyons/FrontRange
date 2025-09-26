//
//  YamsParser.swift
//  FrontRange
//
//  Created by Daniel Lyons on 9/3/25.
//

import Foundation
import OrderedCollections
import Parsing
import Yams

/// A `swift-parsing` wrapper around the `Yams` YAML parser that parses a YAML document into a `FrontMatter`.
public struct YamsParser: Parsing.ParserPrinter {
  public var resolver: Yams.Resolver
  public var constructor: Yams.Constructor
  public var encoding: Yams.Parser.Encoding
  
  public var canonical: Bool
  public var indent: Int
  public var width: Int
  public var allowUnicode: Bool
  public var lineBreak: Yams.Emitter.LineBreak
  public var explicitStart: Bool
  public var explicitEnd: Bool
  public var version: (major: Int, minor: Int)?
  public var sortKeys: Bool
  public var sequenceStyle: Yams.Node.Sequence.Style
  public var mappingStyle: Yams.Node.Mapping.Style
  public var newLineScalarStyle: Yams.Node.Scalar.Style
  public var redundancyAliasingStrategy: (any Yams.RedundancyAliasingStrategy)?
  
  
  public init(
    resolver: Yams.Resolver = .default,
    constructor: Yams.Constructor = .default,
    encoding: Yams.Parser.Encoding = .default,
    canonical: Bool = false,
    indent: Int = 2,
    width: Int = 0,
    allowUnicode: Bool = false,
    lineBreak: Yams.Emitter.LineBreak = .ln,
    explicitStart: Bool = false,
    explicitEnd: Bool = false,
    version: (major: Int, minor: Int)? = nil,
    sortKeys: Bool = false,
    sequenceStyle: Yams.Node.Sequence.Style = .any,
    mappingStyle: Yams.Node.Mapping.Style = .any,
    newLineScalarStyle: Yams.Node.Scalar.Style = .any,
    redundancyAliasingStrategy: (any Yams.RedundancyAliasingStrategy)? = nil
  ) {
    self.resolver = resolver
    self.constructor = constructor
    self.encoding = encoding
    self.canonical = canonical
    self.indent = indent
    self.width = width
    self.allowUnicode = allowUnicode
    self.lineBreak = lineBreak
    self.explicitStart = explicitStart
    self.explicitEnd = explicitEnd
    self.version = version
    self.sortKeys = sortKeys
    self.sequenceStyle = sequenceStyle
    self.mappingStyle = mappingStyle
    self.newLineScalarStyle = newLineScalarStyle
    self.redundancyAliasingStrategy = redundancyAliasingStrategy	
  }
  
  /// Serializes structured ``FrontMatter`` data into unstructured text data.
  public func print(
    _ output: FrontMatter,
    into input: inout Substring
  ) throws {
    let yamlString = try Yams.dump(
      object: output,
      canonical: canonical,
      indent: indent,
      width: width,
      allowUnicode: allowUnicode,
      lineBreak: lineBreak,
      explicitStart: explicitStart,
      explicitEnd: explicitEnd,
      version: version,
      sortKeys: sortKeys,
      sequenceStyle: sequenceStyle,
      mappingStyle: mappingStyle,
      newLineScalarStyle: newLineScalarStyle,
      redundancyAliasingStrategy: redundancyAliasingStrategy
    )
    input = yamlString.trimmingCharacters(in: .newlines) + input
  }
  
  public typealias Input = Substring
  public typealias Output = FrontMatter
  
  /// Parses unstructured text data into structured ``FrontMatter`` data.
  public func parse(_ input: inout Substring) throws -> FrontMatter {
    Swift.print("ℹ️ Parsing input string:\n\(input)")
    
    let dict = try parseYAMLToOrderedDictionary(
      String(input),
    )
    
    input = Substring() // Clear the input since we consumed the entire YAML document
    return dict
  }
  
  /// Parses a YAML string into an `OrderedDictionary` (recursively) while preserving the order of keys as they appear in the YAML.
  public func parseYAMLToOrderedDictionary(_ yamlString: String) throws -> OrderedDictionary<String, Any> {
    // Parse the YAML to get the basic structure
    let loadedYAML: Any? = try Yams.load(yaml: yamlString)
    
    // Convert to ordered structure recursively
    guard
      let loadedYAML = loadedYAML,
      let orderedResult = convertToOrderedStructure(loadedYAML, yamlString: yamlString) as? OrderedDictionary<String, Any>
    else {
      throw YamsParser.Error.notAMappingNode
    }
    
    return orderedResult
  }

  /// Recursively looks for any `Dictionary` in the structure and converts it to `OrderedDictionary` using the key order extracted from the original YAML string.
  private func convertToOrderedStructure(_ value: Any, yamlString: String, currentPath: [String] = []) -> Any {
    if let dictionary = value as? [String: Any] {
      // Convert regular dictionary to OrderedDictionary with preserved order
      return createOrderedDictionary(from: dictionary, yamlString: yamlString, path: currentPath)
    } else if let array = value as? [Any] {
      // Recursively process arrays
      return array.map { convertToOrderedStructure($0, yamlString: yamlString, currentPath: currentPath) }
    } else {
      // Return primitive values as-is
      return value
    }
  }

  private func createOrderedDictionary(from dictionary: [String: Any], yamlString: String, path: [String]) -> OrderedDictionary<String, Any> {
    var orderedDict: OrderedDictionary<String, Any> = [:]
    
    // Extract key order for this specific level
    let keyOrder = extractKeyOrderForPath(from: yamlString, path: path)
    
    // Add keys in the order they appeared in the YAML
    for key in keyOrder {
      if let value = dictionary[key] {
        let processedValue = convertToOrderedStructure(value, yamlString: yamlString, currentPath: path + [key])
        orderedDict[key] = processedValue
      }
    }
    
    // Add any remaining keys that weren't caught by the parsing (edge cases)
    for (key, value) in dictionary {
      if orderedDict[key] == nil {
        let processedValue = convertToOrderedStructure(value, yamlString: yamlString, currentPath: path + [key])
        orderedDict[key] = processedValue
      }
    }
    
    return orderedDict
  }

  private func extractKeyOrderForPath(from yamlString: String, path: [String]) -> [String] {
    let lines = yamlString.components(separatedBy: .newlines)
    var keys: [String] = []
    var currentIndentLevel = 0
    let targetIndentLevel = path.count * 2 // Assuming 2-space indentation
    var isInTargetSection = path.isEmpty // If path is empty, we're looking for root keys
    
    for line in lines {
      let trimmedLine = line.trimmingCharacters(in: .whitespaces)
      
      // Skip comments and empty lines
      if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
        continue
      }
      
      // Calculate indentation level
      let leadingSpaces = line.prefix { $0 == " " }.count
      currentIndentLevel = leadingSpaces
      
      // Check if we're in the right section for nested paths
      if !path.isEmpty {
        if currentIndentLevel == targetIndentLevel && isInTargetSection {
          // We're at the target level and in the right section
          if let colonIndex = trimmedLine.firstIndex(of: ":") {
            let keyPart = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let cleanKey = keyPart.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            if !cleanKey.isEmpty && !keys.contains(cleanKey) {
              keys.append(cleanKey)
            }
          }
        } else if currentIndentLevel < targetIndentLevel {
          // We've moved back to a higher level, check if we're still in the right path
          isInTargetSection = checkIfInPath(line: trimmedLine, path: Array(path.prefix(currentIndentLevel / 2 + 1)))
        } else if currentIndentLevel == targetIndentLevel - 2 {
          // We're at the parent level, check if this matches our path
          isInTargetSection = checkIfInPath(line: trimmedLine, path: path)
        }
      } else {
        // Root level keys
        if currentIndentLevel == 0 {
          if let colonIndex = trimmedLine.firstIndex(of: ":") {
            let keyPart = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let cleanKey = keyPart.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            if !cleanKey.isEmpty && !keys.contains(cleanKey) {
              keys.append(cleanKey)
            }
          }
        }
      }
    }
    
    return keys
  }
  
  private func checkIfInPath(line: String, path: [String]) -> Bool {
    guard !path.isEmpty else { return true }
    
    if let colonIndex = line.firstIndex(of: ":") {
      let keyPart = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
      let cleanKey = keyPart.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
      return cleanKey == path.last
    }
    
    return false
  }
  
  // Enhanced version that handles more complex YAML structures
  private func extractKeyOrderAdvanced(from yamlString: String, path: [String] = []) -> [String] {
    var keys: [String] = []
    let lines = yamlString.components(separatedBy: .newlines)
    
    var yamlStructure: [YAMLSection] = []
    
    for (lineIndex, line) in lines.enumerated() {
      let trimmedLine = line.trimmingCharacters(in: .whitespaces)
      
      if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
        continue
      }
      
      let indentLevel = line.prefix { $0 == " " }.count
      
      if let colonIndex = trimmedLine.firstIndex(of: ":") {
        let keyPart = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        let cleanKey = keyPart.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        
        let section = YAMLSection(
          key: cleanKey,
          indentLevel: indentLevel,
          lineIndex: lineIndex,
          path: calculatePath(indentLevel: indentLevel, previousSections: yamlStructure)
        )
        
        yamlStructure.append(section)
      }
    }
    
    // Filter sections that match the target path
    let targetPath = path
    let matchingSections = yamlStructure.filter { section in
      return section.path == targetPath
    }
    
    // Extract keys in order
    keys = matchingSections.map { $0.key }
    
    return keys
  }
  
  
  /// Helper structures for advanced parsing
  private struct YAMLSection {
    let key: String
    let indentLevel: Int
    let lineIndex: Int
    let path: [String]
  }
  
  private func calculatePath(indentLevel: Int, previousSections: [YAMLSection]) -> [String] {
    var path: [String] = []
    let targetDepth = indentLevel / 2 // Assuming 2-space indentation
    
    // Find parent sections at each level
    for depth in 0..<targetDepth {
      let requiredIndent = depth * 2
      
      // Find the most recent section at this indent level
      if let parentSection = previousSections.last(where: { $0.indentLevel == requiredIndent }) {
        path.append(parentSection.key)
      }
    }
    
    return path
  }
}

extension YamsParser {
  public enum Error: Swift.Error {
    case aliasesNotSupported
    case notAMappingNode
    
    public var errorDescription: String? {
      switch self {
        case .notAMappingNode:
          return "The YAML document is not a mapping node at the root level."
        case .aliasesNotSupported:
          return "YAML aliases are not supported."
      }
    }
  }
}
