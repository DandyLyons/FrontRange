//
//  ConfigTests.swift
//  FrontRange
//
//  Tests for configuration data structures
//

import Foundation
import Testing
import Yams
@testable import FrontRangeCLI

@Suite("Config Data Structure Tests")
struct ConfigTests {

    @Test("FrontRangeConfig initializes with all nil values")
    func testConfigInitialization() {
        let config = FrontRangeConfig()

        #expect(config.canonical == nil)
        #expect(config.indent == nil)
        #expect(config.width == nil)
        #expect(config.allowUnicode == nil)
        #expect(config.lineBreak == nil)
        #expect(config.explicitStart == nil)
        #expect(config.explicitEnd == nil)
        #expect(config.sortKeys == nil)
        #expect(config.sequenceStyle == nil)
        #expect(config.mappingStyle == nil)
        #expect(config.scalarStyle == nil)
    }

    @Test("FrontRangeConfig encodes to YAML correctly")
    func testConfigYAMLEncoding() throws {
        let config = FrontRangeConfig(
            canonical: false,
            indent: 2,
            sortKeys: true,
            sequenceStyle: .block,
            mappingStyle: .flow
        )

        let encoder = YAMLEncoder()
        let yaml = try encoder.encode(config)

        #expect(yaml.contains("canonical: false"))
        #expect(yaml.contains("indent: 2"))
        #expect(yaml.contains("sortKeys: true"))
        #expect(yaml.contains("sequenceStyle: block"))
        #expect(yaml.contains("mappingStyle: flow"))
    }

    @Test("FrontRangeConfig decodes from YAML correctly")
    func testConfigYAMLDecoding() throws {
        let yaml = """
        canonical: false
        indent: 4
        sortKeys: true
        sequenceStyle: flow
        mappingStyle: block
        scalarStyle: plain
        """

        let decoder = YAMLDecoder()
        let config = try decoder.decode(FrontRangeConfig.self, from: yaml)

        #expect(config.canonical == false)
        #expect(config.indent == 4)
        #expect(config.sortKeys == true)
        #expect(config.sequenceStyle == .flow)
        #expect(config.mappingStyle == .block)
        #expect(config.scalarStyle == .plain)
    }

    @Test("LineBreakOption converts to Yams correctly")
    func testLineBreakConversion() {
        #expect(LineBreakOption.cr.toYams() == .cr)
        #expect(LineBreakOption.ln.toYams() == .ln)
        #expect(LineBreakOption.crln.toYams() == .crln)
    }

    @Test("SequenceStyleOption converts to Yams correctly")
    func testSequenceStyleConversion() {
        #expect(SequenceStyleOption.any.toYams() == .any)
        #expect(SequenceStyleOption.block.toYams() == .block)
        #expect(SequenceStyleOption.flow.toYams() == .flow)
    }

    @Test("MappingStyleOption converts to Yams correctly")
    func testMappingStyleConversion() {
        #expect(MappingStyleOption.any.toYams() == .any)
        #expect(MappingStyleOption.block.toYams() == .block)
        #expect(MappingStyleOption.flow.toYams() == .flow)
    }

    @Test("ScalarStyleOption converts to Yams correctly")
    func testScalarStyleConversion() {
        #expect(ScalarStyleOption.any.toYams() == .any)
        #expect(ScalarStyleOption.plain.toYams() == .plain)
        #expect(ScalarStyleOption.singleQuoted.toYams() == .singleQuoted)
        #expect(ScalarStyleOption.doubleQuoted.toYams() == .doubleQuoted)
        #expect(ScalarStyleOption.literal.toYams() == .literal)
        #expect(ScalarStyleOption.folded.toYams() == .folded)
    }
}
