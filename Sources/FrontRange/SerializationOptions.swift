//
//  SerializationOptions.swift
//  FrontRange
//
//  YAML serialization options for FrontMatteredDoc rendering
//

import Foundation
import Yams

/// Options for YAML serialization when rendering front-mattered documents
public struct SerializationOptions: Equatable {
    /// YAML canonical format per spec
    public var canonical: Bool

    /// Indentation increment (number of spaces)
    public var indent: Int

    /// Preferred line width (-1 = unlimited)
    public var width: Int

    /// Allow unescaped non-ASCII characters
    public var allowUnicode: Bool

    /// Line break style
    public var lineBreak: Yams.Emitter.LineBreak

    /// Emit `---` document start marker
    public var explicitStart: Bool

    /// Emit `...` document end marker
    public var explicitEnd: Bool

    /// Sort mapping keys lexicographically
    public var sortKeys: Bool

    /// Sequence/array formatting style
    public var sequenceStyle: Yams.Node.Sequence.Style

    /// Mapping/object formatting style
    public var mappingStyle: Yams.Node.Mapping.Style

    /// Scalar/string formatting style
    public var scalarStyle: Yams.Node.Scalar.Style

    public init(
        canonical: Bool,
        indent: Int,
        width: Int,
        allowUnicode: Bool,
        lineBreak: Yams.Emitter.LineBreak,
        explicitStart: Bool,
        explicitEnd: Bool,
        sortKeys: Bool,
        sequenceStyle: Yams.Node.Sequence.Style,
        mappingStyle: Yams.Node.Mapping.Style,
        scalarStyle: Yams.Node.Scalar.Style
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

    /// Default serialization options
    nonisolated(unsafe) public static let defaults = SerializationOptions(
        canonical: false,
        indent: 2,
        width: -1,
        allowUnicode: false,
        lineBreak: .ln,
        explicitStart: false,
        explicitEnd: false,
        sortKeys: false,
        sequenceStyle: .any,
        mappingStyle: .any,
        scalarStyle: .any
    )
}
