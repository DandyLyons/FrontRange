//
//  ConfigLoader.swift
//  FrontRange
//
//  Loads configuration from files and merges them with precedence
//

import Foundation
import PathKit
import Yams

/// Handles loading and merging of configuration files
public struct ConfigLoader {
    // MARK: - Configuration File Paths

    /// Returns the path to the global configuration file (~/.fr/config.yaml)
    public static func globalConfigPath() -> Path {
        return Path.home + ".fr/config.yaml"
    }

    /// Searches for project configuration file (.fr/config.yaml) by walking up directory tree
    /// - Parameter from: Starting directory path
    /// - Returns: Path to project config if found, nil otherwise
    public static func findProjectConfigPath(from startPath: Path) -> Path? {
        var currentPath = startPath.absolute()

        // Walk up directory tree until we find .fr/config.yaml or reach root
        while true {
            let configPath = currentPath + ".fr/config.yaml"
            if configPath.exists && configPath.isFile {
                return configPath
            }

            // Check if we've reached the root
            let parentPath = currentPath.parent()
            if parentPath == currentPath {
                // We're at the root, stop searching
                break
            }

            currentPath = parentPath
        }

        return nil
    }

    // MARK: - Loading Configuration

    /// Load global configuration from ~/.fr/config.yaml
    /// - Returns: Configuration if file exists and is valid, nil if file doesn't exist
    /// - Throws: If file exists but cannot be parsed
    public static func loadGlobalConfig() throws -> FrontRangeConfig? {
        let path = globalConfigPath()
        return try loadConfig(from: path)
    }

    /// Load project configuration by searching up directory tree from starting path
    /// - Parameter from: Starting directory to search from
    /// - Returns: Configuration if file found and valid, nil if not found
    /// - Throws: If file exists but cannot be parsed
    public static func loadProjectConfig(from startPath: Path) throws -> FrontRangeConfig? {
        guard let configPath = findProjectConfigPath(from: startPath) else {
            return nil
        }
        return try loadConfig(from: configPath)
    }

    /// Load configuration from a specific file path
    /// - Parameter path: Path to config file
    /// - Returns: Configuration if file exists and is valid, nil if file doesn't exist
    /// - Throws: If file exists but cannot be parsed
    private static func loadConfig(from path: Path) throws -> FrontRangeConfig? {
        // Return nil if file doesn't exist (not an error)
        guard path.exists else {
            return nil
        }

        guard path.isFile else {
            throw ConfigError.notAFile(path: path.string)
        }

        // Read file content
        let content = try path.read(.utf8)

        // Parse YAML
        let decoder = YAMLDecoder()
        do {
            let config = try decoder.decode(FrontRangeConfig.self, from: content)
            return config
        } catch {
            throw ConfigError.parseError(path: path.string, underlyingError: error)
        }
    }

    // MARK: - Merging Configurations

    /// Merge multiple configurations with precedence
    /// - Parameter configs: Array of configs where later configs have higher precedence
    /// - Returns: Merged configuration with non-nil values from higher precedence configs overriding lower precedence
    public static func mergeConfigs(_ configs: [FrontRangeConfig?]) -> FrontRangeConfig {
        var merged = FrontRangeConfig()

        for config in configs.compactMap({ $0 }) {
            // For each field, if config has a non-nil value, it overrides the merged value
            if let canonical = config.canonical {
                merged.canonical = canonical
            }
            if let indent = config.indent {
                merged.indent = indent
            }
            if let width = config.width {
                merged.width = width
            }
            if let allowUnicode = config.allowUnicode {
                merged.allowUnicode = allowUnicode
            }
            if let lineBreak = config.lineBreak {
                merged.lineBreak = lineBreak
            }
            if let explicitStart = config.explicitStart {
                merged.explicitStart = explicitStart
            }
            if let explicitEnd = config.explicitEnd {
                merged.explicitEnd = explicitEnd
            }
            if let sortKeys = config.sortKeys {
                merged.sortKeys = sortKeys
            }
            if let sequenceStyle = config.sequenceStyle {
                merged.sequenceStyle = sequenceStyle
            }
            if let mappingStyle = config.mappingStyle {
                merged.mappingStyle = mappingStyle
            }
            if let scalarStyle = config.scalarStyle {
                merged.scalarStyle = scalarStyle
            }
        }

        return merged
    }
}

// MARK: - Configuration Errors

public enum ConfigError: Error, CustomStringConvertible {
    case notAFile(path: String)
    case parseError(path: String, underlyingError: Error)

    public var description: String {
        switch self {
        case .notAFile(let path):
            return "Configuration path is not a file: \(path)"
        case .parseError(let path, let error):
            return "Failed to parse configuration file at \(path): \(error.localizedDescription)"
        }
    }
}
