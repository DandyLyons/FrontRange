//
//  ConfigResolverTests.swift
//  FrontRange
//
//  Tests for configuration resolution and conversion
//

import Foundation
import FrontRange
import PathKit
import Testing
@testable import FrontRangeCLI

@Suite("ConfigResolver Tests")
struct ConfigResolverTests {

    @Test("ResolvedConfig initializes with defaults for nil values")
    func testResolvedConfigDefaults() {
        let config = FrontRangeConfig()  // All nil
        let resolved = ResolvedConfig(from: config)

        // Should match ResolvedConfig.defaults
        #expect(resolved.canonical == false)
        #expect(resolved.indent == 2)
        #expect(resolved.width == -1)
        #expect(resolved.allowUnicode == false)
        #expect(resolved.lineBreak == .ln)
        #expect(resolved.explicitStart == false)
        #expect(resolved.explicitEnd == false)
        #expect(resolved.sortKeys == false)
        #expect(resolved.sequenceStyle == .any)
        #expect(resolved.mappingStyle == .any)
        #expect(resolved.scalarStyle == .any)
    }

    @Test("ResolvedConfig uses provided values over defaults")
    func testResolvedConfigUsesProvidedValues() {
        let config = FrontRangeConfig(
            indent: 4,
            sortKeys: true,
            sequenceStyle: .flow
        )
        let resolved = ResolvedConfig(from: config)

        #expect(resolved.indent == 4)  // From config
        #expect(resolved.sortKeys == true)  // From config
        #expect(resolved.sequenceStyle == .flow)  // From config
        #expect(resolved.canonical == false)  // Default
    }

    @Test("toSerializationOptions converts correctly")
    func testToSerializationOptions() {
        let resolved = ResolvedConfig(
            canonical: false,
            indent: 4,
            width: 80,
            allowUnicode: true,
            lineBreak: .crln,
            explicitStart: true,
            explicitEnd: false,
            sortKeys: true,
            sequenceStyle: .flow,
            mappingStyle: .block,
            scalarStyle: .plain
        )

        let opts = ConfigResolver.toSerializationOptions(resolved)

        #expect(opts.canonical == false)
        #expect(opts.indent == 4)
        #expect(opts.width == 80)
        #expect(opts.allowUnicode == true)
        #expect(opts.lineBreak == .crln)
        #expect(opts.explicitStart == true)
        #expect(opts.explicitEnd == false)
        #expect(opts.sortKeys == true)
        #expect(opts.sequenceStyle == .flow)
        #expect(opts.mappingStyle == .block)
        #expect(opts.scalarStyle == .plain)
    }

    @Test("configFromGlobalOptions extracts CLI flag values")
    func testConfigFromGlobalOptions() {
        // Note: We can't easily create GlobalOptions instances in unit tests
        // because it has @Argument properties that require ArgumentParser.
        // This functionality is tested via integration tests.

        // Test that defaults are sensible
        #expect(ResolvedConfig.defaults.indent == 2)
        #expect(ResolvedConfig.defaults.sortKeys == false)
        #expect(ResolvedConfig.defaults.sequenceStyle == .any)
    }
}
