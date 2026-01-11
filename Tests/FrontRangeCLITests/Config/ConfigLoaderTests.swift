//
//  ConfigLoaderTests.swift
//  FrontRange
//
//  Tests for configuration loading and merging
//

import Foundation
import PathKit
import Testing
@testable import FrontRangeCLI

@Suite("ConfigLoader Tests")
struct ConfigLoaderTests {

    @Test("loadGlobalConfig returns nil when file doesn't exist")
    func testLoadGlobalConfigMissing() throws {
        // Global config won't exist in test environment
        let config = try ConfigLoader.loadGlobalConfig()
        #expect(config == nil)
    }

    @Test("loadProjectConfig returns nil when file doesn't exist")
    func testLoadProjectConfigMissing() throws {
        let tempDir = Path("/tmp/fr-test-\(UUID().uuidString)")
        try tempDir.mkdir()
        defer { try? tempDir.delete() }

        let config = try ConfigLoader.loadProjectConfig(from: tempDir)
        #expect(config == nil)
    }

    @Test("loadConfig parses valid YAML config")
    func testLoadValidConfig() throws {
        let tempDir = Path("/tmp/fr-test-\(UUID().uuidString)")
        try tempDir.mkdir()
        defer { try? tempDir.delete() }

        let configPath = tempDir + ".fr/config.yaml"
        try configPath.parent().mkdir()

        let yaml = """
        sortKeys: true
        indent: 4
        sequenceStyle: flow
        """
        try configPath.write(yaml)

        let config = try ConfigLoader.loadProjectConfig(from: tempDir)

        #expect(config != nil)
        #expect(config?.sortKeys == true)
        #expect(config?.indent == 4)
        #expect(config?.sequenceStyle == .flow)
    }

    @Test("loadConfig throws on invalid YAML")
    func testLoadInvalidYAML() throws {
        let tempDir = Path("/tmp/fr-test-\(UUID().uuidString)")
        try tempDir.mkdir()
        defer { try? tempDir.delete() }

        let configPath = tempDir + ".fr/config.yaml"
        try configPath.parent().mkdir()

        let invalidYaml = """
        sortKeys: [invalid
        """
        try configPath.write(invalidYaml)

        #expect(throws: ConfigError.self) {
            try ConfigLoader.loadProjectConfig(from: tempDir)
        }
    }

    @Test("findProjectConfig walks up directory tree")
    func testFindProjectConfigWalksUp() throws {
        let tempDir = Path("/tmp/fr-test-\(UUID().uuidString)")
        try tempDir.mkdir()
        defer { try? tempDir.delete() }

        let configPath = tempDir + ".fr/config.yaml"
        try configPath.parent().mkdir()
        try configPath.write("sortKeys: true")

        let nestedDir = tempDir + "nested/deeply"
        try nestedDir.mkpath()

        let foundPath = ConfigLoader.findProjectConfigPath(from: nestedDir)
        #expect(foundPath == configPath)
    }

    @Test("mergeConfigs applies precedence correctly")
    func testMergeConfigsPrecedence() {
        let config1 = FrontRangeConfig(
            indent: 2,
            sortKeys: true,
            sequenceStyle: .block
        )

        let config2 = FrontRangeConfig(
            indent: 4,  // Should override config1
            mappingStyle: .flow  // New value
        )

        let merged = ConfigLoader.mergeConfigs([config1, config2])

        #expect(merged.indent == 4)  // From config2 (higher precedence)
        #expect(merged.sortKeys == true)  // From config1
        #expect(merged.sequenceStyle == .block)  // From config1
        #expect(merged.mappingStyle == .flow)  // From config2
    }

    @Test("mergeConfigs handles nil configs")
    func testMergeConfigsWithNils() {
        let config1 = FrontRangeConfig(indent: 2)
        let config2: FrontRangeConfig? = nil
        let config3 = FrontRangeConfig(sortKeys: true)

        let merged = ConfigLoader.mergeConfigs([config1, config2, config3])

        #expect(merged.indent == 2)
        #expect(merged.sortKeys == true)
    }

    @Test("mergeConfigs returns empty config when all nil")
    func testMergeConfigsAllNil() {
        let merged = ConfigLoader.mergeConfigs([nil, nil, nil])

        #expect(merged.indent == nil)
        #expect(merged.sortKeys == nil)
        #expect(merged.sequenceStyle == nil)
    }
}
