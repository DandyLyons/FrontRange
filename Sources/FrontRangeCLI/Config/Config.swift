//
//  Config.swift
//  FrontRange
//
//  Configuration data structures for YAML formatting options
//

import ArgumentParser
import Foundation
import Yams

/// Configuration for YAML serialization formatting.
/// All fields are optional to allow partial configuration.
public struct FrontRangeConfig: Codable, Equatable {
    /// YAML canonical format per spec
    public var canonical: Bool?

    /// Indentation increment (number of spaces)
    public var indent: Int?

    /// Preferred line width (-1 = unlimited)
    public var width: Int?

    /// Allow unescaped non-ASCII characters
    public var allowUnicode: Bool?

    /// Line break style
    public var lineBreak: LineBreakOption?

    /// Emit `---` document start marker
    public var explicitStart: Bool?

    /// Emit `...` document end marker
    public var explicitEnd: Bool?

    /// Sort mapping keys lexicographically
    public var sortKeys: Bool?

    /// Sequence/array formatting style
    public var sequenceStyle: SequenceStyleOption?

    /// Mapping/object formatting style
    public var mappingStyle: MappingStyleOption?

    /// Scalar/string formatting style
    public var scalarStyle: ScalarStyleOption?

    public init(
        canonical: Bool? = nil,
        indent: Int? = nil,
        width: Int? = nil,
        allowUnicode: Bool? = nil,
        lineBreak: LineBreakOption? = nil,
        explicitStart: Bool? = nil,
        explicitEnd: Bool? = nil,
        sortKeys: Bool? = nil,
        sequenceStyle: SequenceStyleOption? = nil,
        mappingStyle: MappingStyleOption? = nil,
        scalarStyle: ScalarStyleOption? = nil
    ) {
        self.canonical = canonical
        self.indent = indent
        self.width = width
        self.allowUnicode = allowUnicode
        self.lineBreak = lineBreak
        self.explicitStart = explicitStart
        self.explicitEnd = explicitEnd
        self.sortKeys = sortKeys
        self.sequenceStyle = sequenceStyle
        self.mappingStyle = mappingStyle
        self.scalarStyle = scalarStyle
    }
}

// MARK: - Codable Wrapper Enums for Yams Types

/// Line break style options
public enum LineBreakOption: String, Codable, CaseIterable, ExpressibleByArgument {
    case cr    // Carriage Return (Mac classic)
    case ln    // Line Feed / LF (Unix/Linux/macOS)
    case crln  // CRLF (Windows DOS style)

    /// Convert to Yams.Emitter.LineBreak
    func toYams() -> Yams.Emitter.LineBreak {
        switch self {
        case .cr: return .cr
        case .ln: return .ln
        case .crln: return .crln
        }
    }
}

/// Sequence/array formatting style options
public enum SequenceStyleOption: String, Codable, CaseIterable, ExpressibleByArgument {
    case any    // Let emitter choose (default)
    case block  // Bullet list style: - item
    case flow   // Inline style: [item1, item2, item3]

    /// Convert to Yams.Node.Sequence.Style
    func toYams() -> Yams.Node.Sequence.Style {
        switch self {
        case .any: return .any
        case .block: return .block
        case .flow: return .flow
        }
    }
}

/// Mapping/dictionary formatting style options
public enum MappingStyleOption: String, Codable, CaseIterable, ExpressibleByArgument {
    case any    // Let emitter choose (default)
    case block  // Standard indented format: key: value
    case flow   // Inline format: {key1: value1, key2: value2}

    /// Convert to Yams.Node.Mapping.Style
    func toYams() -> Yams.Node.Mapping.Style {
        switch self {
        case .any: return .any
        case .block: return .block
        case .flow: return .flow
        }
    }
}

/// Scalar/string formatting style options
public enum ScalarStyleOption: String, Codable, CaseIterable, ExpressibleByArgument {
    case any           // Let emitter choose (default)
    case plain         // Unquoted: simple string
    case singleQuoted  // Single quotes: 'string with "quotes"'
    case doubleQuoted  // Double quotes: "string with 'quotes'"
    case literal       // Multi-line, preserves newlines: |
    case folded        // Multi-line, wraps text: >

    /// Convert to Yams.Node.Scalar.Style
    func toYams() -> Yams.Node.Scalar.Style {
        switch self {
        case .any: return .any
        case .plain: return .plain
        case .singleQuoted: return .singleQuoted
        case .doubleQuoted: return .doubleQuoted
        case .literal: return .literal
        case .folded: return .folded
        }
    }
}
