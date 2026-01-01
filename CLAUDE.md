# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

FrontRange is a Swift package for parsing, mutating, serializing, and deserializing text documents with YAML front matter. It provides:

1. **FrontRange Library** - Core library for working with front-mattered documents
2. **fr CLI** - Command-line tool for managing front matter in text files
3. **FrontRangeMCP** - Model Context Protocol (MCP) server for front matter operations

## Distribution

- **Main Repository:** https://github.com/DandyLyons/FrontRange (library and source code)
- **Homebrew Tap:** https://github.com/DandyLyons/homebrew-frontrange (macOS installation via Homebrew)

## Release Process

FrontRange uses an automated release workflow powered by GitHub Actions. The workflow is triggered when a version tag is pushed.

### Creating a New Release

1. **Update version numbers** in:
   - `Sources/FrontRangeCLI/FrontRangeCLIEntry.swift` (CLI version)
   - `Sources/FrontRangeMCP/main.swift` (MCP server version)

2. **Commit and push** version changes to main branch

3. **Create and push a tag**:
   ```bash
   git tag v0.3.0-beta
   git push origin v0.3.0-beta
   ```

4. **Automated workflow** (.github/workflows/release.yml) will:
   - Build universal binaries (arm64 + x86_64) for `fr` and `frontrange-mcp`
   - Create a tarball archive with both executables
   - Create a GitHub release (marked as pre-release if tag contains beta/alpha/rc)
   - Automatically update the Homebrew formula with new URL and SHA256

### First-Time Setup

The automated release workflow requires a GitHub personal access token:

1. Create a personal access token with `public_repo` scope
2. Add it to repository secrets as `FRONTRANGE_COMMITTER_TOKEN`
3. The workflow uses this token to commit formula updates to the homebrew-frontrange repository

### Release Artifacts

Each release provides:
- **Source code** (automatic GitHub archive)
- **Pre-built binaries** (universal macOS binaries in tarball)
- **Homebrew formula** (automatically updated in DandyLyons/homebrew-frontrange)

Users can install via:
```bash
brew tap DandyLyons/frontrange
brew install frontrange
```

No compilation required - users get instant installation with pre-built binaries.

## Requirements

- **Swift 6.2** or later (as defined in Package.swift)

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
- Subcommands: `get`, `set`, `has`, `list`, `rename`, `remove`, `replace`, `sort-keys`, `lines`, `search`

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

### Replace Command (FrontRangeCLI)

**Replace.swift** (Sources/FrontRangeCLI/Commands/Replace.swift)
- Replace entire front matter with new structured data (JSON, YAML, plist)
- Accepts data via `--data` (inline) or `--from-file` (from file)
- Interactive confirmation prompt (per file) for safety
- Validates input is a mapping/dictionary (rejects arrays/scalars)
- Uses shared DataParsing utility for format conversion

**DataParsing.swift** (Sources/FrontRange/JSON/DataParsing.swift)
- Shared parsing utility for JSON/YAML/plist → `Yams.Node.Mapping`
- Inverse of existing `Node+JSON.swift` (which goes Node → JSON)
- `parseToMapping()` validates input is a mapping
- Used by both CLI and MCP implementations

**ReplaceTool.swift** (Sources/FrontRangeMCP/Tools/Implementations/ReplaceTool.swift)
- MCP tool for programmatic front matter replacement
- Non-interactive (no confirmation prompt - caller is responsible)
- Uses same DataParsing utility as CLI

### Search Command (FrontRangeCLI)

**Search.swift** (Sources/FrontRangeCLI/Commands/Search.swift)
- Search files by evaluating JMESPath expressions against front matter
- Recursively searches directories for matching files
- Converts `Yams.Node.Mapping` to Swift dictionaries for JMESPath evaluation
- Returns file paths of matches (supports JSON, YAML, plain text output)

**JMESPath Literal Syntax - THE ONE TRUE WAY:**
- **ALWAYS** use backticks for ALL literal values:
  - Booleans: `` `true` ``, `` `false` ``
  - Strings: `` `"text"` ``
  - Numbers: `` `42` ``, `` `3.14` ``
  - Null: `` `null` ``
- **ALWAYS** wrap queries in shell single quotes to prevent backtick interpretation

**Example usage:**
```bash
# Find draft files
fr search 'draft == `true`' ./posts

# Find files with specific tags
fr search 'contains(tags, `"swift"`)' .

# Complex queries with mixed types
fr search 'draft == `false` && contains(tags, `"tutorial"`)' ./content
```

**Piping to other commands:**
The search command outputs file paths (one per line), making it ideal for piping to other `fr` commands for bulk operations:

```bash
# Bulk update: mark all drafts as published
fr search 'draft == `true`' ./posts | xargs fr set --key draft --value false

# Chain operations with while loop
fr search 'ready == `true`' . | while read -r file; do
  fr set "$file" --key published --value true
  fr set "$file" --key date --value "$(date +%Y-%m-%d)"
done

# Remove a key from matching files
fr search 'deprecated == `true`' . | xargs fr remove --key temporary
```

### CSV Dump Format (FrontRangeCLI)

The dump command supports CSV export for multiple files, where each row represents a file and each column represents a front matter property.

**File:** `Sources/FrontRangeCLI/Commands/Dump.swift`
- Supports `--multi-format csv` for tabular output
- Three column strategies: union, intersection, custom
- Uses TinyCSV library for RFC 4180 compliant encoding
- Leverages existing `--format` flag to control nested data serialization

**Helper Module:** `Sources/FrontRangeCLI/Helpers/CSVHelpers.swift`
- `CSVGenerator` struct handles CSV generation
- Column determination logic (union/intersection/custom)
- Column alignment ensures all rows have same structure
- Format-aware cell serialization for nested structures

**Column Strategies:**

1. **union (default)**: Include all keys from any file
   - Missing values appear as empty cells
   - Most flexible, shows all available data

2. **intersection**: Only include keys present in ALL files
   - More compact output
   - May hide data if files have different schemas

3. **custom**: User-specified columns via `--csv-custom-columns`
   - Maximum control over output
   - Specify exact columns needed

**Nested Data Handling:**

The `--format` flag controls how complex values (arrays, objects) are serialized in CSV cells:
- `--format json` (default): Serialize as JSON strings
- `--format yaml`: Serialize as YAML strings
- `--format plist`: Serialize as PropertyList XML strings

**CSV Output Structure:**
- First column: `path` (file path)
- Remaining columns: Front matter keys (alphabetically sorted for union/intersection)
- RFC 4180 compliant escaping for commas, quotes, newlines
- Header row included by default

**Example usage:**

```bash
# Export all front matter as CSV (union strategy)
fr dump posts/*.md --multi-format csv

# CSV with only common columns
fr dump posts/*.md --multi-format csv --csv-columns intersection

# CSV with custom columns
fr dump posts/*.md --multi-format csv --csv-columns custom --csv-custom-columns "title,author,date"

# CSV with nested data as YAML strings
fr dump posts/*.md --multi-format csv --format yaml

# Recursive directory export
fr dump posts/ -r --multi-format csv --csv-columns custom --csv-custom-columns "title,date,tags"
```

**Limitations:**
- CSV format requires multiple files (single file raises error)
- Custom column strategy requires `--csv-custom-columns` to be specified
- Column alignment is handled automatically (all rows have same number of cells)

## Dependencies

- **Yams** - YAML parsing and serialization
- **swift-parsing** - Parser combinators for FrontMatteredDoc parser
- **swift-argument-parser** - CLI argument parsing
- **JMESPath** - JMESPath query language for searching/filtering
- **PathKit** - File path handling in CLI
- **TinyCSV** - RFC 4180 compliant CSV encoding/decoding for dump command
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
