//
//  ConfigResolver.swift
//  FrontRange
//
//  Resolves final configuration from multiple sources and converts to Yams options
//

import Foundation
import FrontRange
import PathKit
import Yams

/// Resolves configuration from multiple sources with precedence and converts to Yams options
public struct ConfigResolver {
    // MARK: - Resolution

    /// Resolve final configuration from all sources
    /// Precedence (lowest to highest): defaults < global config < project config < CLI flags
    /// - Parameters:
    ///   - globalOptions: CLI options (may contain formatting flags)
    ///   - workingDirectory: Directory to start searching for project config
    /// - Returns: Fully resolved configuration with all concrete values
    static func resolve(
        globalOptions: GlobalOptions,
        workingDirectory: Path
    ) throws -> ResolvedConfig {
        // 1. Load global config
        let globalConfig = try ConfigLoader.loadGlobalConfig()

        // 2. Load project config
        let projectConfig = try ConfigLoader.loadProjectConfig(from: workingDirectory)

        // 3. Create config from CLI flags
        let cliConfig = configFromGlobalOptions(globalOptions)

        // 4. Merge configs with precedence (lowest to highest)
        let merged = ConfigLoader.mergeConfigs([globalConfig, projectConfig, cliConfig])

        // 5. Fill in defaults for any remaining nil values
        return ResolvedConfig(from: merged)
    }

    /// Extract configuration values from GlobalOptions CLI flags
    private static func configFromGlobalOptions(_ options: GlobalOptions) -> FrontRangeConfig {
        return FrontRangeConfig(
            canonical: options.canonical ? true : nil,  // Only set if flag is present
            indent: options.indent,
            width: options.width,
            allowUnicode: options.allowUnicode ? true : nil,  // Only set if flag is present
            lineBreak: options.lineBreak,
            explicitStart: options.explicitStart ? true : nil,  // Only set if flag is present
            explicitEnd: options.explicitEnd ? true : nil,  // Only set if flag is present
            sortKeys: options.sortKeys ? true : nil,  // Only set if flag is present
            sequenceStyle: options.sequenceStyle,
            mappingStyle: options.mappingStyle,
            scalarStyle: options.scalarStyle
        )
    }

    // MARK: - Conversion to Yams Options

    /// Convert resolved configuration to serialization options
    static func toSerializationOptions(_ config: ResolvedConfig) -> SerializationOptions {
        return SerializationOptions(
            canonical: config.canonical,
            indent: config.indent,
            width: config.width,
            allowUnicode: config.allowUnicode,
            lineBreak: config.lineBreak.toYams(),
            explicitStart: config.explicitStart,
            explicitEnd: config.explicitEnd,
            sortKeys: config.sortKeys,
            sequenceStyle: config.sequenceStyle.toYams(),
            mappingStyle: config.mappingStyle.toYams(),
            scalarStyle: config.scalarStyle.toYams()
        )
    }
}

// MARK: - Resolved Configuration

/// Configuration with all values resolved (no optionals)
public struct ResolvedConfig: Equatable {
    public var canonical: Bool
    public var indent: Int
    public var width: Int
    public var allowUnicode: Bool
    public var lineBreak: LineBreakOption
    public var explicitStart: Bool
    public var explicitEnd: Bool
    public var sortKeys: Bool
    public var sequenceStyle: SequenceStyleOption
    public var mappingStyle: MappingStyleOption
    public var scalarStyle: ScalarStyleOption

    /// Create ResolvedConfig from partial FrontRangeConfig, filling in defaults for nil values
    init(from config: FrontRangeConfig) {
        self.canonical = config.canonical ?? ResolvedConfig.defaults.canonical
        self.indent = config.indent ?? ResolvedConfig.defaults.indent
        self.width = config.width ?? ResolvedConfig.defaults.width
        self.allowUnicode = config.allowUnicode ?? ResolvedConfig.defaults.allowUnicode
        self.lineBreak = config.lineBreak ?? ResolvedConfig.defaults.lineBreak
        self.explicitStart = config.explicitStart ?? ResolvedConfig.defaults.explicitStart
        self.explicitEnd = config.explicitEnd ?? ResolvedConfig.defaults.explicitEnd
        self.sortKeys = config.sortKeys ?? ResolvedConfig.defaults.sortKeys
        self.sequenceStyle = config.sequenceStyle ?? ResolvedConfig.defaults.sequenceStyle
        self.mappingStyle = config.mappingStyle ?? ResolvedConfig.defaults.mappingStyle
        self.scalarStyle = config.scalarStyle ?? ResolvedConfig.defaults.scalarStyle
    }

    /// Direct initializer with all values
    public init(
        canonical: Bool,
        indent: Int,
        width: Int,
        allowUnicode: Bool,
        lineBreak: LineBreakOption,
        explicitStart: Bool,
        explicitEnd: Bool,
        sortKeys: Bool,
        sequenceStyle: SequenceStyleOption,
        mappingStyle: MappingStyleOption,
        scalarStyle: ScalarStyleOption
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

    /// Built-in default configuration values
    nonisolated(unsafe) public static let defaults = ResolvedConfig(
        canonical: false,
        indent: 2,
        width: -1,  // unlimited
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
