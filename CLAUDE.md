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
- Supports all date filtering options (see Date Handling section)

**Architectural Note:**
The Search command duplicates date filtering options and logic from GlobalOptions due to ArgumentParser constraints. Search has a unique signature `fr search <query> <paths>...` with two positional @Arguments (query and paths), which conflicts with GlobalOptions' @Argument for paths. ArgumentParser doesn't support multiple @Argument declarations when using @OptionGroup. Rather than refactor the entire GlobalOptions architecture, the date filtering code is intentionally duplicated in Search.swift with inline comments documenting this decision.

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

## Date Handling

FrontRange provides comprehensive date support for working with dates in front matter and file system metadata.

### Date Modules

**Date Parsing** (`Sources/FrontRange/Date/`)
- **DateParsing.swift**: Multi-format date parsing using Swift Foundation's Date.ParseStrategy API
- **WikiLinkDateParser.swift**: Parse wiki-link style dates like `[[2026-01-01]]`
- **DateRange.swift**: Date range comparison utilities

**File Metadata** (`Sources/FrontRange/FileMetadata/`)
- **FileMetadata.swift**: Access file system dates (created, modified, added)
- **Path+Metadata.swift**: PathKit extension for convenient metadata access

### Supported Date Formats

FrontRange automatically detects and parses the following date formats:

1. **ISO 8601** (recommended for interchange)
   - `2023-10-01T00:00:00Z`
   - `2023-10-01T14:30:00+00:00`
   - `2023-10-01`

2. **Year-Month-Day** (unambiguous)
   - `YYYY-MM-DD`: `2023-10-01`
   - `YYYY/MM/DD`: `2023/10/01`

3. **Month-Day-Year** (US format)
   - `MM/DD/YYYY`: `10/01/2023`
   - `MM-DD-YYYY`: `10-01-2023`

4. **Day-Month-Year** (European format)
   - `DD/MM/YYYY`: `01/10/2023`
   - `DD-MM-YYYY`: `01-10-2023`

5. **Wiki Links** (for zettelkasten workflows)
   - `[[2026-01-01]]`

6. **Custom Format Strings**
   - Support for custom DateFormatter format strings

### File System Date Filtering

GlobalOptions provides date filtering flags to keep only files matching date constraints:

**Modified Date Filters:**
```bash
--modified-after YYYY-MM-DD    # Keep files modified after this date
--modified-before YYYY-MM-DD   # Keep files modified before this date
--modified-month YYYY-MM       # Keep files modified in this month
```

**Created Date Filters:**
```bash
--created-after YYYY-MM-DD     # Keep files created after this date
--created-before YYYY-MM-DD    # Keep files created before this date
--created-month YYYY-MM        # Keep files created in this month
```

**Added Date Filters** (macOS only via Spotlight):
```bash
--added-after YYYY-MM-DD       # Keep files added after this date
--added-before YYYY-MM-DD      # Keep files added before this date
--added-month YYYY-MM          # Keep files added in this month
```

### Date Filtering Examples

```bash
# Keep files modified after January 1, 2024
fr dump posts/ --modified-after 2024-01-01

# Keep files created before December 31, 2024
fr dump posts/ --created-before 2024-12-31

# Keep files modified in January 2024
fr dump posts/ --modified-month 2024-01

# Combine date filters with front matter search
fr search 'draft == `false`' posts/ --modified-after 2024-01-01

# Multiple date constraints (created in 2024, modified recently)
fr dump posts/ --created-after 2024-01-01 --modified-after 2024-12-01

# CSV export with file metadata columns
fr dump posts/*.md --multi-format csv --include-file-metadata
```

### CSV with File Metadata

The dump command supports including file system metadata in CSV exports:

**Flag:** `--include-file-metadata`

When enabled, adds three columns after the path column:
- `created`: File creation date (ISO8601)
- `modified`: File modification date (ISO8601)
- `added`: File added date (ISO8601, macOS only)

**Example output:**
```csv
path,created,modified,added,title,author,date
posts/a.md,2024-01-01T10:00:00Z,2024-01-15T14:30:00Z,2024-01-01T11:00:00Z,"Post A","Alice","2024-01-01"
posts/b.md,2024-02-01T09:00:00Z,2024-02-10T16:00:00Z,2024-02-01T09:30:00Z,"Post B","Bob","2024-02-01"
```

**Usage:**
```bash
# CSV with file metadata
fr dump posts/*.md --multi-format csv --include-file-metadata

# Combine with custom columns
fr dump posts/*.md --multi-format csv --csv-columns custom --csv-custom-columns "title,author" --include-file-metadata

# Filter by date AND export metadata
fr dump posts/ -r --modified-after 2024-01-01 --multi-format csv --include-file-metadata
```

### Date Handling in Front Matter

**Storage:** Dates in front matter remain as YAML scalar strings (ISO8601 format recommended)

**Comparison:** For JMESPath queries in search command, ISO 8601 dates can be compared as strings:
```bash
# Find posts from 2024 onwards (string comparison works for ISO 8601)
fr search 'date >= `"2024-01-01"`' posts/

# Find posts in specific month
fr search 'starts_with(date, `"2024-01"`)' posts/

# Combine front matter and file system dates
fr search 'draft == `false`' posts/ --modified-after 2024-01-01
```

**Best Practice:** Always use ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ) for dates in front matter to ensure reliable string-based comparisons and cross-platform compatibility.

### Architecture Notes

- **Library stays format-agnostic**: Core FrontRange library stores dates as YAML scalar strings
- **Parsing at CLI layer**: Date parsing happens in CLI commands when consuming data
- **Modern Swift APIs**: Uses Foundation's Date.ParseStrategy API for date parsing (DateFormatter for fallback cases)
- **Zero external dependencies**: Date parsing relies only on Swift Foundation APIs
- **Platform-specific**: "Added date" only available on macOS via Spotlight metadata
- **Graceful degradation**: Missing metadata returns nil instead of throwing errors

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

## JSONSchema Validation (NEW)

FrontRange now supports JSONSchema validation of front matter. **Validation is 100% opt-in** - it never runs automatically.

### Overview

Validate front matter against JSONSchema definitions to ensure data quality and consistency. Validation must be explicitly requested via:
- `fr validate` command
- `--validate` flag on `fr set` and `fr replace` commands
- `validate_frontmatter` MCP tool

### Core Components

**SchemaValidator** (`Sources/FrontRange/Validation/SchemaValidator.swift`)
- Validates `FrontMatteredDoc` against JSONSchema
- Converts `Yams.Node.Mapping` to Swift dictionaries for validation
- Returns `ValidationResult` with detailed violations

**SchemaResolver** (`Sources/FrontRange/Validation/SchemaResolver.swift`)
- Loads schemas from files, URLs, or project config
- Priority: CLI flag > embedded `$schema` > project config
- Caches schemas for performance
- Auto-detects project root (searches for `.git`)

**ValidationResult** (`Sources/FrontRange/Validation/ValidationResult.swift`)
- Contains validation status and violations
- `ValidationViolation`: JSONPath, message, expected, actual
- `ValidationSummary`: Statistics for batch operations

**ProjectConfig** (`Sources/FrontRange/Config/ProjectConfig.swift`)
- Parses `.frontrange.yml` from project root
- Maps file patterns (globs) to schema paths
- Defines validation settings (exclude patterns, cache)

### Schema Resolution Priority

1. **Explicit CLI flag**: `--schema` or `--validate-schema`
2. **Embedded `$schema` key**: In frontmatter itself
3. **Project config**: `.frontrange.yml` glob pattern match
4. **None**: Gracefully returns nil (no validation)

### CLI Commands

**fr validate**
```bash
# Validate with explicit schema
fr validate posts/*.md --schema schemas/blog-post.json

# Use embedded $schema key
fr validate post.md

# Recursive with project config
fr validate . --recursive

# JSON output for CI/CD
fr validate posts/ --format json --schema schemas/post.json

# Continue on errors
fr validate . -r --continue-on-error
```

Output formats: `detailed` (default), `summary`, `json`, `yaml`

Exit codes: `0` (valid), `1` (invalid), `2` (errors)

**fr set --validate**
```bash
# Set value with validation
fr set --key draft --value false post.md --validate --validate-schema schemas/post.json

# If validation fails, file is NOT modified
```

**fr replace --validate**
```bash
# Replace with validation
fr replace post.md --data '{"title": "New"}' --format json --validate

# Validation runs BEFORE confirmation prompt
# If invalid, skips prompt and exits
```

### MCP Tool

**validate_frontmatter**
```json
{
  "path": "post.md",
  "schema": "schemas/blog-post.json",
  "format": "json"
}
```

Returns: Structured validation results with `isError` flag

### Project Config (.frontrange.yml)

Place in project root to define schema mappings:

```yaml
# Schema mappings (glob pattern → schema path)
schemas:
  "content/posts/**/*.md": "schemas/blog-post.json"
  "content/pages/**/*.md": "schemas/page.json"
  "**/*.md": "schemas/default.json"

# Validation settings (when validation IS enabled)
validation:
  exclude:
    - "drafts/**"
    - "temp/**"
  cache_schemas: true
```

**IMPORTANT**: Having this config file does NOT enable validation automatically. Validation is always opt-in.

### Example Schema

```json
{
  "type": "object",
  "required": ["title", "date", "draft"],
  "properties": {
    "title": {
      "type": "string",
      "minLength": 1
    },
    "date": {
      "type": "string",
      "format": "date"
    },
    "draft": {
      "type": "boolean"
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  }
}
```

### Testing

**Unit Tests** (`Tests/FrontRangeTests/Validation/`)
- SchemaValidator: Validation logic
- SchemaResolver: Schema loading and resolution
- ProjectConfig: Config parsing and glob matching

**CLI Integration Tests** (`Tests/FrontRangeCLITests/`)
- Validate command with various options
- Set/Replace with --validate flag
- Error handling and exit codes

### Design Principles

1. **100% Opt-In**: Validation NEVER runs automatically
2. **Fail-Fast**: Invalid documents block mutations
3. **Detailed Errors**: JSONPath to violations, expected vs actual
4. **Flexible**: Multiple schema sources (CLI, embedded, config)
5. **Performant**: Schema caching, batch processing
6. **User-Friendly**: Clear messages, multiple output formats

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
