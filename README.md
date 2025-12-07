# FrontRange

A Swift package for parsing, mutating, serializing, and deserializing text documents with YAML front matter.

## Overview

FrontRange provides three complementary tools for working with front-mattered documents:

1. **FrontRange Library** - Core Swift library for programmatic front matter manipulation
2. **fr CLI** - Command-line tool for managing front matter in text files
3. **FrontRangeMCP** - Model Context Protocol (MCP) server for AI-powered front matter operations

## Features

- Parse documents with YAML front matter
- Get, set, check, list, rename, and remove front matter keys
- **Search files using JMESPath queries** (filter by front matter values)
- Sort front matter keys alphabetically or in reverse order
- Extract specific line ranges from files
- Support for multiple output formats (JSON, YAML, plain text)
- Comprehensive test coverage
- Swift 6.2+ with modern concurrency support

## Installation

### Swift Package Manager

Add FrontRange to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/FrontRange.git", from: "0.1.0")
]
```

### Building from Source

```bash
git clone https://github.com/yourusername/FrontRange.git
cd FrontRange
swift build
```

## Usage

### Library

Use the `FrontMatteredDoc` type to work with front-mattered documents in your Swift code:

```swift
import FrontRange

// Parse a document
let content = """
---
title: My Document
author: Jane Doe
tags: [swift, yaml]
---
# Document Content
This is the body of the document.
"""

let doc = try FrontMatteredDoc(parsing: content)

// Get values
if let title = doc.getValue(forKey: "title") {
    print(title) // Yams.Node representing "My Document"
}

// Set values
var mutableDoc = doc
mutableDoc.setValue("New Title", forKey: "title")

// Check for keys
let hasAuthor = mutableDoc.hasKey("author") // true

// Remove keys
mutableDoc.remove(key: "tags")

// Render back to string
let output = try mutableDoc.render()
print(output)
```

### CLI Tool (fr)

The `fr` command-line tool provides quick access to front matter operations:

#### Get a value

```bash
fr get document.md --key title
# Output: My Document

fr get document.md --key title --format json
# Output: "My Document"
```

#### Set a value

```bash
fr set document.md --key author --value "John Smith"
```

#### Check if a key exists

```bash
fr has document.md --key title
# Output: Files containing key 'title': document.md
```

#### List all keys

```bash
fr list document.md
# Output:
# - title
# - author
# - tags

fr list document.md --format json
# Output: ["title", "author", "tags"]
```

#### Rename a key

```bash
fr rename document.md --key author --new-key writer
```

#### Remove a key

```bash
fr remove document.md --key tags
```

#### Sort keys

```bash
fr sort-keys document.md
# Sorts keys alphabetically

fr sort-keys document.md --order reverse
# Sorts keys in reverse alphabetical order
```

#### Extract lines

```bash
fr lines document.md --start 1 --end 10
# Extract lines 1-10

fr lines document.md --start 5
# Extract from line 5 to end

fr lines document.md --end 20
# Extract from start to line 20
```

#### Search files with JMESPath queries

Search for files whose front matter matches a JMESPath expression:

```bash
# Find all draft files
fr search 'draft == `true`' ./posts

# Find files with specific tag
fr search 'contains(tags, `"swift"`)' .

# Complex queries
fr search 'draft == `false` && contains(tags, `"tutorial"`)' ./content

# Output formats
fr search 'draft == `true`' . --format json
```

**Important**: Use single quotes around queries to prevent shell interpretation of backticks. Boolean and number literals in JMESPath require backticks (`` `true` ``, `` `false` ``, `` `42` ``).

### Workflow Examples

#### Bulk Update Files with Search + Set

A powerful pattern is to pipe search results into the `set` command for bulk updates:

```bash
# Find all draft posts and mark them as published
fr search 'draft == `true`' ./posts | xargs fr set --key draft --value false

# Add a "reviewed" tag to all tutorial posts
fr search 'contains(tags, `"tutorial"`)' ./content | xargs fr set --key reviewed --value true

# Update author on all posts from a specific category
fr search 'category == `"getting-started"`' . | \
  xargs fr set --key author --value "Documentation Team"
```

**How it works:**
1. `fr search` outputs matching file paths (one per line)
2. `xargs` reads those paths and passes them to `fr set`
3. `fr set` updates all files with the specified key-value pair

**Using `-I` for complex pipelines:**

For more control, use `xargs -I {}` to place file paths explicitly:

```bash
# Archive old drafts by adding an archive date
fr search 'draft == `true` && year < `2024`' ./posts | \
  xargs -I {} fr set {} --key archived_date --value "2025-12-06"

# Chain multiple operations
fr search 'status == `"review"`' ./posts | while read -r file; do
  fr set "$file" --key status --value "published"
  fr set "$file" --key published_date --value "$(date +%Y-%m-%d)"
done
```

**Real-world use case:** Publishing a batch of blog posts

```bash
# Step 1: Find all ready-to-publish posts
fr search 'draft == `true` && ready == `true`' ./blog/posts

# Step 2: Review the list, then publish them all
fr search 'draft == `true` && ready == `true`' ./blog/posts | \
  xargs fr set --key draft --value false
```

#### Global Options

- `--format, -f`: Output format (json, yaml, plainString)
- `--recursive, -r`: Process directories recursively
- `--extensions, -e`: File extensions to process (default: md,markdown,yml,yaml)

#### Enable Debug Output

Set the `FRONTRANGE_DEBUG` environment variable to see detailed execution information:

```bash
FRONTRANGE_DEBUG=1 fr get document.md --key title
```

### MCP Server (FrontRangeMCP)

The FrontRangeMCP server implements the [Model Context Protocol](https://modelcontextprotocol.io), allowing AI assistants like Claude to manage front matter in your documents.

**Note:** The MCP server is currently in early development.

#### Running the Server

```bash
swift build
.build/debug/frontrange-mcp
```

#### Testing with MCP Inspector

The MCP Inspector provides a web interface for testing the server:

```bash
# Install the inspector (requires Node.js)
npm install -g @modelcontextprotocol/inspector

# Run the inspector with your server
npx @modelcontextprotocol/inspector .build/debug/frontrange-mcp
```

#### Configuring with Claude Desktop

Add the server to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "frontrange": {
      "command": "/path/to/FrontRange/.build/debug/frontrange-mcp"
    }
  }
}
```

#### Available MCP Tools

The server provides 8 tools that mirror the CLI functionality:

- **get** - Get a value from front matter by key
- **set** - Set a value in front matter
- **has** - Check if a key exists
- **list** - List all front matter keys
- **rename** - Rename a front matter key
- **remove** - Remove a key from front matter
- **sort_keys** - Sort front matter keys
- **lines** - Extract line ranges from files

#### Example MCP Usage

Once configured, you can ask Claude:

> "Get the title from my document.md"

> "Set the author field to 'Jane Doe' in all markdown files in this directory"

> "List all front matter keys in my blog posts"

> "Sort the front matter keys alphabetically in article.md"

## Development

### Building

```bash
# Build everything
swift build

# Build specific targets
swift build --target FrontRange
swift build --target FrontRangeCLI
swift build --target FrontRangeMCP
```

### Testing

```bash
# Run all tests
swift test

# Run specific test suites
swift test --filter FrontRangeTests
swift test --filter FrontRangeCLITests
swift test --filter FrontRangeMCPTests
```

### Running the CLI in Development

```bash
swift run fr get example.md --key title
```

### Running the MCP Server in Development

```bash
swift run frontrange-mcp
```

## Architecture

### Core Types

- **FrontMatteredDoc** - Main data structure representing a document with YAML front matter
- **FrontMatteredDoc.Parser** - Parser/printer for front-mattered documents using swift-parsing
- **GlobalOptions** - Shared CLI options for file processing

### Front Matter Storage

Front matter is stored as `Yams.Node.Mapping`, preserving YAML semantics rather than converting to plain Swift dictionaries. This ensures round-trip fidelity and support for YAML-specific features.

### Dependencies

- [Yams](https://github.com/jpsim/Yams) - YAML parsing and serialization
- [swift-parsing](https://github.com/pointfreeco/swift-parsing) - Parser combinators
- [swift-argument-parser](https://github.com/apple/swift-argument-parser) - CLI argument parsing
- [PathKit](https://github.com/kylef/PathKit) - File path handling
- [MCP Swift SDK](https://github.com/modelcontextprotocol/swift-sdk) - Model Context Protocol implementation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Acknowledgments

- Built with the [Model Context Protocol Swift SDK](https://github.com/modelcontextprotocol/swift-sdk)
- Uses [Yams](https://github.com/jpsim/Yams) for YAML processing
- Command-line parsing powered by [swift-argument-parser](https://github.com/apple/swift-argument-parser)
