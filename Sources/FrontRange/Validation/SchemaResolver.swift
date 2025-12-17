//
//  SchemaResolver.swift
//  FrontRange
//
//  Created by Claude Code on 2025-12-17.
//

import Foundation
import JSONSchema
import Yams

/// Resolves and loads JSONSchema definitions from various sources
public class SchemaResolver {
  private var schemaCache: [String: Schema] = [:]
  private let cacheSchemas: Bool

  /// Initialize a schema resolver
  ///
  /// - Parameter cacheSchemas: Whether to cache loaded schemas for performance (default: true)
  public init(cacheSchemas: Bool = true) {
    self.cacheSchemas = cacheSchemas
  }

  /// Resolve a schema based on priority: explicit path, embedded $schema, or config
  ///
  /// Priority order:
  /// 1. Explicit schema path (from CLI --schema flag)
  /// 2. Embedded $schema key in frontmatter
  /// 3. Project config (future: Phase 3)
  /// 4. nil (no schema found - graceful)
  ///
  /// - Parameters:
  ///   - explicit: Explicit schema path from CLI flag
  ///   - embedded: Embedded $schema value from frontmatter
  ///   - filePath: File path being validated (for config lookup in Phase 3)
  /// - Returns: Resolved Schema or nil if no schema found
  /// - Throws: ValidationError if schema loading fails
  public func resolveSchema(
    explicit: String?,
    embedded: Yams.Node?,
    filePath: String? = nil
  ) throws -> Schema? {
    // Priority 1: Explicit CLI flag
    if let explicitPath = explicit {
      return try loadSchema(from: explicitPath)
    }

    // Priority 2: Embedded $schema key in frontmatter
    if let schemaNode = embedded,
       let schemaPath = extractStringFromNode(schemaNode) {
      return try loadSchema(from: schemaPath)
    }

    // Priority 3: Project config (TODO: Phase 3)
    // if let config = self.config,
    //    let configSchemaPath = config.schemaPath(for: filePath) {
    //   return try loadSchema(from: configSchemaPath)
    // }

    // Priority 4: No schema found (graceful)
    return nil
  }

  /// Load a schema from a file path or URL
  ///
  /// - Parameter path: File path or URL to schema
  /// - Returns: Loaded and parsed Schema
  /// - Throws: ValidationError if loading or parsing fails
  public func loadSchema(from path: String) throws -> Schema {
    // Check cache first
    if cacheSchemas, let cached = schemaCache[path] {
      return cached
    }

    // Load schema data
    let schemaData: Data
    do {
      schemaData = try loadSchemaData(from: path)
    } catch {
      throw ValidationError.schemaLoadFailed(path, underlyingError: error)
    }

    // Parse schema
    let schema: Schema
    do {
      // JSONSchema.Schema expects JSON data
      let jsonObject = try JSONSerialization.jsonObject(with: schemaData)
      guard let schemaDict = jsonObject as? [String: Any] else {
        throw ValidationError.schemaInvalid("Schema must be a JSON object, not an array or primitive")
      }
      schema = Schema(schemaDict)
    } catch let error as ValidationError {
      throw error
    } catch {
      throw ValidationError.schemaInvalid("Failed to parse schema: \(error.localizedDescription)")
    }

    // Cache if enabled
    if cacheSchemas {
      schemaCache[path] = schema
    }

    return schema
  }

  /// Clear the schema cache
  public func clearCache() {
    schemaCache.removeAll()
  }

  // MARK: - Private Helpers

  /// Load schema data from file path or URL
  private func loadSchemaData(from path: String) throws -> Data {
    // Check if it's a URL
    if path.hasPrefix("http://") || path.hasPrefix("https://") {
      // URL loading (Phase 6: Advanced Features)
      // For now, throw an error
      throw ValidationError.schemaLoadFailed(
        path,
        underlyingError: NSError(
          domain: "FrontRange",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "URL schema loading not yet implemented. Use file paths for now."]
        )
      )
    }

    // Load from file path
    let url = URL(fileURLWithPath: path)
    do {
      return try Data(contentsOf: url)
    } catch {
      // Try expanding tilde in path
      let expandedPath = (path as NSString).expandingTildeInPath
      let expandedURL = URL(fileURLWithPath: expandedPath)
      return try Data(contentsOf: expandedURL)
    }
  }

  /// Extract string value from Yams.Node
  private func extractStringFromNode(_ node: Yams.Node) -> String? {
    guard case .scalar = node else {
      return nil
    }
    return String.construct(from: node)
  }
}
