# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

FrontRange is a Swift package for parsing, mutating, serializing, and deserializing text documents with YAML front matter. It provides:

1. **FrontRange Library** - Core library for working with front-mattered documents
2. **fr CLI** - Command-line tool for managing front matter in text files
3. **FrontRangeMCP** - Model Context Protocol (MCP) server for front matter operations

## Build and Test Commands

```bash
# Build the entire package
swift build

# Build specific targets
swift build --target FrontRange
swift build --target FrontRangeCLI
swift build --target FrontRangeMCP

# Run tests
swift test

# Run tests for specific targets
swift test --filter FrontRangeTests
swift test --filter FrontRangeCLITests
swift test --filter FrontRangeMCPTests

# Run the CLI tool in development
swift run fr <command>
swift run fr get --key <key> --path <file>

# Run the MCP server
swift run frontrange-mcp
```

## MCP Server Development

The FrontRangeMCP server implements the Model Context Protocol. To develop and test:

```bash
# Start the MCP server
swift run frontrange-mcp

# Start the MCP Inspector (requires Node.js/npm)
npx @modelcontextprotocol/inspector /path/to/FrontRange/.build/debug/frontrange-mcp
```

Note: The MCP server is currently in early development.

## Architecture

### Core Library (FrontRange)

**`FrontMatteredDoc`** (Sources/FrontRange/FrontMatteredDoc/FrontMatteredDoc.swift)
- Central data structure representing a document with YAML front matter
- Structure: `frontMatter: Yams.Node.Mapping` + `body: String`
- Key operations: `getValue()`, `setValue()`, `hasKey()`, `remove()`, `renameKey()`, `render()`

**Parser** (Sources/FrontRange/FrontMatteredDoc/FrontMatteredDoc.Parser.swift)
- Uses swift-parsing library for parser-printer pattern
- Expected format: `---\n[YAML]---\n[body]`
- Converts YAML front matter to `Yams.Node.Mapping`

**YAML Integration**
- Uses Yams library for YAML parsing/serialization
- Front matter is stored as `Yams.Node.Mapping` (not plain Swift dictionaries)
- Custom `_Pair` type in YamsSupport/ extends Yams functionality

### CLI Tool (FrontRangeCLI)

**Entry Point** (Sources/FrontRangeCLI/FrontRangeCLIEntry.swift)
- Uses swift-argument-parser
- Main command: `fr`
- Subcommands: `get`, `set`, `has`, `list`, `rename`, `remove`, `sort-keys`, `lines`

**Subcommand Pattern**
- Each subcommand is a struct conforming to `ParsableCommand`
- Located in Sources/FrontRangeCLI/Commands/
- Uses `@OptionGroup var options: GlobalOptions` for shared options

**Global Options** (Sources/FrontRangeCLI/GlobalOptions.swift)
- `--path` / `-p`: File path(s) to process
- `--format` / `-f`: Output format (yaml, json, raw)
- `--debug` / `-d`: Enable debug output

### MCP Server (FrontRangeMCP)

**Server Setup** (Sources/FrontRangeMCP/main.swift)
- Uses ModelContextProtocol Swift SDK
- Runs on stdio transport
- Server name: "FrontRangeMCP", version: "0.0.1"

**Tool Registration** (Sources/FrontRangeMCP/Tools/Tools.swift)
- Tools defined in `ThisServer.tools` array
- Tool execution handled by `runTool()` function
- Current tools: `hello_world` (working), `get` (placeholder)

## Dependencies

- **Yams** - YAML parsing and serialization
- **swift-parsing** - Parser combinators for FrontMatteredDoc parser
- **swift-argument-parser** - CLI argument parsing
- **PathKit** - File path handling in CLI
- **swift-custom-dump** - Testing utilities
- **Command** - Programmatic CLI testing
- **MCP Swift SDK** - Model Context Protocol server implementation

## Testing Patterns

### CLI Testing
- Uses the Command library to invoke CLI programmatically
- Helper functions in Tests/FrontRangeCLITests/CLI Test Helpers.swift:
  - `createTempFile(withContent:)` - Create temporary files for testing
  - `copyIntoTempFile(source:)` - Copy files to temporary locations
- Test plan files use `.xctestplan` format

### Library Testing
- Standard XCTest patterns
- CustomDump for assertion comparisons
- Example files in ExampleFiles/ directory used for integration tests

## Working with Yams Nodes

When manipulating front matter, remember:

```swift
// Keys and values are Yams.Node types, not plain Swift types
doc.getValue(forKey: "title")  // Returns Yams.Node?
doc.setValue(.scalar(.init("value")), forKey: "key")

// Convenience methods exist for common types
doc.setValue("string value", forKey: "key")  // String
doc.setValue(42, forKey: "key")             // Int

// Direct node manipulation
doc.frontMatter[.scalar(.init("key"))] = .scalar(.init("value"))
```

## Key Patterns and Conventions

1. **Parser-Printer Pattern**: FrontMatteredDoc.Parser implements both parsing (string → struct) and printing (struct → string)

2. **Node-based API**: Front matter operations work with `Yams.Node` types, not plain Swift dictionaries. This preserves YAML semantics.

3. **Mutating Methods**: Methods that modify front matter are marked `mutating` since FrontMatteredDoc is a struct.

4. **Error Handling**: Most operations throw errors rather than returning optionals. Parse errors, missing keys, etc. are thrown.

5. **Global Options Pattern**: CLI commands share common options via `@OptionGroup var options: GlobalOptions`.

## File Structure Notes

- Example files for testing: ExampleFiles/
- Build artifacts: .build/ (git-ignored)
- Three distinct target groups: FrontRange (lib), FrontRangeCLI (executable), FrontRangeMCP (executable)
- Tests mirror the source structure with corresponding test targets
