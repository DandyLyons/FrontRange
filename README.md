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
- **Replace entire front matter** with structured data (JSON, YAML, plist)
- **Search files using JMESPath queries** (filter by front matter values)
- **Array manipulation commands** (check, append, prepend, remove values from arrays)
- Sort front matter keys alphabetically or in reverse order
- Extract specific line ranges from files
- Support for multiple output formats (JSON, YAML, plain text)
- Comprehensive test coverage
- Swift 6.2+ with modern concurrency support

## Installation

### Homebrew (macOS)

Install the CLI tool and MCP server via Homebrew:

```bash
# Add the tap
brew tap DandyLyons/frontrange

# Install FrontRange
brew install frontrange
```

The Homebrew formula is maintained in a separate repository: [DandyLyons/homebrew-frontrange](https://github.com/DandyLyons/homebrew-frontrange)

**Note:** The Homebrew formula builds FrontRange from source during installation, requiring Swift Command Line Tools on your system.

### Swift Package Manager

Add FrontRange to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/DandyLyons/FrontRange.git", from: "0.1.0")
]
```

### Building from Source

```bash
git clone https://github.com/DandyLyons/FrontRange.git
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

The `fr` command-line tool provides quick access to front matter operations.

#### Installation & Running

**For regular use (recommended):**
```bash
# Install globally (method depends on your setup)
# Once installed, invoke directly:
fr <command> [options]
```

**For development/testing:**
```bash
# From the FrontRange project directory:
swift run fr <command> [options]
```

This guide assumes `fr` is installed and available in your PATH. Use `swift run fr` only when developing or testing FrontRange itself.

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

#### Replace entire front matter

**DESTRUCTIVE** - Replace the complete front matter with new structured data. The command prompts for confirmation before making changes.

```bash
# Replace with inline JSON
fr replace document.md --data '{"title": "New Title", "draft": false}' --format json

# Replace from YAML file
fr replace document.md --from-file metadata.yaml --format yaml

# Replace from plist file
fr replace document.md --from-file config.plist --format plist

# Process multiple files (prompted once per file)
fr replace posts/ -r --from-file template.json --format json
```

**Input methods:**
- `--data`: Inline data string
- `--from-file`: Read from file (mutually exclusive with --data)

**Supported formats:**
- `json`: JavaScript Object Notation (default)
- `yaml`: YAML Ain't Markup Language
- `plist`: Apple PropertyList XML

**Note:** Front matter must be a dictionary/mapping. Arrays and scalars will be rejected with validation errors.

#### Search files with JMESPath queries

Search for files whose front matter matches a JMESPath expression. The `search` command **always searches recursively** through all subdirectories.

```bash
# Find all draft files (automatically recursive)
fr search 'draft == `true`' ./posts

# Find files with specific tag (simpler than JMESPath)
fr array contains --key tags --value swift .

# Complex queries with mixed types
fr search 'draft == `false` && tags' ./content

# Output formats
fr search 'draft == `true`' . --format json
```

**Understanding search output:**

The search command outputs file paths (one per line) to stdout. Progress messages like "Processing batch..." are sent to stderr and won't interfere with piping:

```bash
$ fr search 'draft == `true`' ./posts
Processing batch 1/4...  # stderr - progress indicator
Processing batch 2/4...  # stderr - progress indicator
/Users/user/posts/draft1.md  # stdout - actual results
/Users/user/posts/draft2.md  # stdout - actual results
```

To suppress progress messages: `fr search 'draft == `true`' . 2>/dev/null`

##### Understanding JMESPath + Shell Syntax

**The conflict:** JMESPath uses backticks (`` ` ``) for literals, but shells use backticks for command substitution. This creates a syntax challenge.

**The solution:**

1. **Always use backticks for ALL JMESPath literal values:**
   - Booleans: `` `true` ``, `` `false` ``
   - Strings: `` `"text"` `` (backticks + quotes)
   - Numbers: `` `42` ``, `` `3.14` ``
   - Null: `` `null` ``

2. **Always wrap the entire query in shell single quotes:**
   ```bash
   fr search 'draft == `true` && author == `"Jane"`' .
   ```

This combination prevents the shell from interpreting backticks as command substitution while allowing JMESPath to recognize all literals correctly.

**Common mistakes:**
```bash
# ✗ Wrong - shell interprets backticks
fr search "draft == `true`" .

# ✗ Wrong - JMESPath treats "true" as field name
fr search 'draft == true' .

# ✓ Correct - single quotes + backtick literals
fr search 'draft == `true`' .

# ✓ Better - use array contains for simpler, more readable syntax
fr array contains --key tags --value swift .
```

#### Array manipulation commands

The `array` command group provides operations for working with arrays in front matter. All commands support case-insensitive operations via the `-i` flag.

**Check if array contains a value:**

```bash
# Find files where tags array contains "swift"
fr array contains --key tags --value swift posts/

# Find files with specific alias (case-insensitive)
fr array contains --key aliases --value blue -i ./

# Invert: find files that DON'T contain the value
fr array contains --key tags --value deprecated --invert posts/

# Output in plain text (one path per line)
fr array contains --key tags --value swift posts/ --format plainString
```

**Add values to arrays:**

```bash
# Append value to end of array
fr array append --key tags --value tutorial posts/*.md

# Append only if value doesn't exist (prevent duplicates)
fr array append --key tags --value swift --skip-duplicates posts/*.md

# Prepend value to beginning of array (useful for priority ordering)
fr array prepend --key tags --value featured posts/*.md

# Case-insensitive duplicate check
fr array append --key tags --value SWIFT -i --skip-duplicates posts/*.md
```

**Remove values from arrays:**

```bash
# Remove first occurrence of value from array
fr array remove --key tags --value draft posts/*.md

# Case-insensitive removal
fr array remove --key tags --value SWIFT -i posts/*.md
```

**Common features:**
- String comparison only (bool/null/int/float not currently supported)
- Case-sensitive by default, `-i` flag for case-insensitive operations
- Pipe-friendly output for bulk operations
- Files without the key or non-array values are silently skipped (for contains) or throw errors (for mutating operations)

**Piping array commands together:**

```bash
# Find files with "draft" tag and remove it
fr array contains --key tags --value draft posts/ | xargs fr array remove --key tags --value draft

# Add "published" tag to all non-draft posts
fr array contains --key tags --value draft --invert posts/ | xargs fr array append --key tags --value published

# Chain multiple operations
fr array contains --key tags --value swift . | while read -r file; do
  fr array append "$file" --key tags --value programming --skip-duplicates
  fr array prepend "$file" --key tags --value featured
done
```

**When to use array commands vs search:**
- Use `array contains` for simple "does array contain X?" checks
- Use `array append/prepend/remove` for bulk array modifications
- Use `search` for complex queries, multiple conditions, or non-array fields

### Workflow Examples

#### Bulk Update Files with Search + Set

A powerful pattern is to pipe search results into other `fr` commands for bulk updates. However, there are important considerations for reliable bulk operations.

##### Choosing the Right Approach

Different scenarios call for different piping strategies:

| Scenario                                                  | Recommended Method   | Reason                        |
| --------------------------------------------------------- | -------------------- | ----------------------------- |
| Few files (<100), no spaces in paths                      | `xargs`              | Fast and simple               |
| Few files (<100), paths with spaces or special characters | `xargs -I`           | Handles spaces in paths       |
| Paths with spaces or special characters                   | `while read -r` loop | Handles quoting correctly     |
| Large file sets (100+ files)                              | `while read -r` loop | Avoids system argument limits |
| Multi-step operations per file                            | `while read -r` loop | Easier to read and debug      |
| Generating structured output (JSON, etc.)                 | Bash script file     | Full control over formatting  |

##### Using xargs (Simple Cases)

For straightforward operations on small file sets without spaces in paths:

```bash
# Find all draft posts and mark them as published
fr search 'draft == `true`' ./posts | xargs fr set --key draft --value false

# Add a "reviewed" tag to all tutorial posts
fr array contains --key tags --value tutorial ./content | xargs fr set --key reviewed --value true
```

**Important limitations of xargs:**

1. **System argument limits:** Most systems limit total arguments to ~4096. With thousands of files, you'll hit this limit:
   ```bash
   # May fail: too many arguments (5008) -- limit is 4096
   fr search 'tags' large-directory/ | xargs fr get --key tags

   # Solution: batch with -n flag
   fr search 'tags' large-directory/ | xargs -n 50 fr get --key tags
   ```

2. **Spaces in paths:** By default, xargs treats spaces as delimiters:
   ```bash
   # Fails with paths like "/path/My Documents/file.md"
   fr search 'tags' . | xargs fr get --key tags

   # Solution: use -I flag for explicit placement
   fr search 'tags' . | xargs -I {} fr get --key tags "{}"
   ```

##### Using while read Loops (Recommended for Most Cases)

The `while read -r` pattern handles spaces, special characters, and large file counts reliably:

```bash
# Publish and date-stamp matching posts
fr search 'draft == `true` && ready == `true`' ./posts | while read -r file; do
  fr set "$file" --key draft --value false
  fr set "$file" --key published --value true
  fr set "$file" --key published_date --value "$(date +%Y-%m-%d)"
  fr remove "$file" --key ready
done
```

**Benefits:**
- Handles spaces and special characters in paths automatically
- No argument count limits
- Easy to add error handling
- Clear multi-step logic

**With error handling:**

```bash
# Only process files that actually have the key
fr search 'tags' . | while read -r file; do
  tags=$(fr get --key tags "$file" 2>&1)

  # Skip files where key wasn't found
  if [[ ! "$tags" =~ "not found" ]] && [[ ! "$tags" =~ "Error" ]]; then
    echo "$file: $tags"
  fi
done
```

##### Advanced: Complex Operations with Bash Scripts

For repeatable operations or generating structured output, create a standalone bash script:

```bash
#!/bin/bash
# Save as publish_drafts.sh

echo "Publishing drafts..."
count=0

fr search 'draft == `true` && ready == `true`' ./posts | while read -r file; do
  echo "Processing: $file"

  # Multiple operations per file
  fr set "$file" --key draft --value false
  fr set "$file" --key published --value true
  fr set "$file" --key published_date --value "$(date +%Y-%m-%d)"
  fr remove "$file" --key ready

  count=$((count + 1))
done

echo "Published $count posts"
```

Run it: `chmod +x publish_drafts.sh && ./publish_drafts.sh`

**Real-world example: Extracting structured data**

When you need to generate JSON or other structured output from many files with complex paths:

```bash
#!/bin/bash
# extract_tags.sh - Generate JSON mapping of book names to tags

echo "{"

books=(
  "/Users/user/Library/The Bible (WEB)/01 - Genesis/Genesis.md"
  "/Users/user/Library/The Bible (WEB)/02 - Exodus/Exodus.md"
  # ... more files with spaces and special characters
)

total=${#books[@]}
count=0

for book_path in "${books[@]}"; do
  count=$((count + 1))

  if [ -f "$book_path" ]; then
    book_name=$(basename "$book_path" .md)
    tags=$(fr get --key tags "$book_path" 2>&1)

    # Only output if tags were found
    if [[ ! "$tags" =~ "not found" ]] && [[ ! "$tags" =~ "Error" ]]; then
      echo -n "  \"$book_name\": $tags"

      # Add comma except for last item
      if [ $count -lt $total ]; then
        echo ","
      else
        echo ""
      fi
    fi
  fi
done

echo "}"
```

Output: `./extract_tags.sh > bible_tags.json`

This approach provides:
- Full control over output format
- Proper handling of special characters
- Error handling and validation
- Maintainable, reusable code

#### Handling Missing Keys and Errors

Not all files will have all front matter keys. When a key is missing, `fr` commands output an error message:

```bash
$ fr get document.md --key tags
Error: Key 'tags' not found in frontmatter.
```

**Strategies for handling missing keys:**

1. **Filter first with search** - Only process files that have the key:
```bash
# Search only returns files where 'tags' exists
fr search 'tags' . | while read -r file; do
  fr get --key tags "$file"
done
```

2. **Suppress expected errors** - When it's normal for some files to be missing the key:
```bash
# Get tags from all files, quietly skip files without tags
fr get --key tags posts/ -r 2>/dev/null
```

3. **Check for errors in scripts** - Handle errors programmatically:
```bash
tags=$(fr get --key tags "$file" 2>&1)

if [[ ! "$tags" =~ "not found" ]] && [[ ! "$tags" =~ "Error" ]]; then
  echo "Tags found: $tags"
else
  echo "No tags in $file"
fi
```

#### YAML Formatting Configuration

FrontRange provides comprehensive control over YAML output formatting through a flexible configuration system that supports CLI flags, project-level config files, and global user preferences.

##### Configuration Precedence

Configuration is resolved in order of priority (highest to lowest):

1. **CLI Flags** - Command-line arguments (e.g., `--indent 4`)
2. **Project Config** - `.frontrange.yaml` in the current directory
3. **Global Config** - `~/.config/frontrange/config.yaml`
4. **Defaults** - Built-in defaults

##### Configuration Files

**Global Config (`~/.config/frontrange/config.yaml`):**
User-specific preferences that apply to all `fr` commands on your system.

```yaml
# Personal preferences
indent: 2
width: 100
allowUnicode: true
sortKeys: true
```

**Project Config (`.frontrange.yaml`):**
Team-shareable settings for a specific project (commit to version control).

```yaml
# Team-wide formatting standards
indent: 4
width: 80
sortKeys: true
sequenceStyle: block
mappingStyle: block
scalarStyle: doubleQuoted
```

##### Available Options

All YAML serialization options:

- `canonical` (bool): Canonical YAML format
- `indent` (int): Indentation spaces (default: 2)
- `width` (int): Line width for wrapping (default: 80, -1 = unlimited)
- `allowUnicode` (bool): Allow Unicode characters (default: false)
- `lineBreak` (string): `cr`, `ln`, or `crln` (default: `ln`)
- `explicitStart` (bool): Include `---` document start (default: false)
- `explicitEnd` (bool): Include `...` document end (default: false)
- `sortKeys` (bool): Sort keys alphabetically (default: false)
- `sequenceStyle` (string): Array format - `any`, `block`, or `flow` (default: `any`)
- `mappingStyle` (string): Object format - `any`, `block`, or `flow` (default: `any`)
- `scalarStyle` (string): String format - `any`, `plain`, `singleQuoted`, `doubleQuoted`, `literal`, or `folded` (default: `any`)

##### CLI Flag Overrides

All write commands support formatting flags that override configuration files:

```bash
# Override config to use 2-space indentation
fr set --key title --value "Hello" post.md --indent 2

# Force canonical YAML output
fr set --key author --value "Alice" post.md --canonical

# Use flow style for arrays (inline: [1, 2, 3])
fr array append --key tags --value swift post.md --sequence-style flow

# Sort keys alphabetically
fr set --key date --value "2024-01-01" post.md --sort-keys

# Combine multiple formatting options
fr set --key title --value "Post" post.md --indent 4 --width 120 --sort-keys
```

##### Use Cases

**Team Consistency:**
Ensure all team members use the same YAML formatting:

```bash
# Create project config
cat > .frontrange.yaml << EOF
indent: 2
sortKeys: true
sequenceStyle: block
EOF

# Commit to version control
git add .frontrange.yaml
git commit -m "Add FrontRange config for consistent YAML formatting"
```

**Personal Preferences:**
Set your preferred formatting globally:

```bash
# Create global config directory
mkdir -p ~/.config/frontrange

# Set preferences
cat > ~/.config/frontrange/config.yaml << EOF
allowUnicode: true
width: 120
indent: 2
EOF
```

**One-off Overrides:**
Override defaults for specific operations:

```bash
# Usually use 2-space indent, but need 4 for this file
fr set --key title --value "Special" post.md --indent 4
```

**Standardize Formatting:**
Reformat all files with consistent settings:

```bash
# Bulk reformat all posts
for file in posts/*.md; do
  fr sort-keys "$file" --indent 2 --sort-keys --sequence-style block
done
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

The server provides 9 tools that mirror the CLI functionality:

- **get** - Get a value from front matter by key
- **set** - Set a value in front matter
- **has** - Check if a key exists
- **list** - List all front matter keys
- **rename** - Rename a front matter key
- **remove** - Remove a key from front matter
- **replace** - Replace entire front matter with structured data
- **sort_keys** - Sort front matter keys
- **lines** - Extract line ranges from files

#### Example MCP Usage

> [!NOTE] Early Development
> The MCP server is in early development and may have limited functionality or stability. Feedback and issues are much appreciated.

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

## Releasing a New Version

For maintainers releasing a new version:

**1. Tag and push the release:**
```bash
git tag v0.3.0-beta
git push origin v0.3.0-beta
```

**2. Create GitHub release:**
- Visit [Releases](https://github.com/DandyLyons/FrontRange/releases)
- Draft a new release using the tag
- Write release notes
- Publish (GitHub auto-generates source tarballs)

**3. Update Homebrew formula:**
```bash
cd ../homebrew-frontrange

# Get SHA256 for the new tarball
curl -LO https://github.com/DandyLyons/FrontRange/archive/refs/tags/v0.3.0-beta.tar.gz
shasum -a 256 v0.3.0-beta.tar.gz

# Edit Formula/frontrange.rb:
# - Update URL to new version
# - Update SHA256 checksum
# - Update version in test assertion

git add Formula/frontrange.rb
git commit -m "Update FrontRange to v0.3.0-beta"
git push
```

See [homebrew-frontrange/CLAUDE.md](https://github.com/DandyLyons/homebrew-frontrange/blob/main/CLAUDE.md) for detailed formula maintenance guide.

## Contributing

Please submitt issues via GitHub for bugs or feature requests. Pull requests are welcome, but I won't accept any until I first decide on the license for this project.

## Acknowledgments

- Built with the [Model Context Protocol Swift SDK](https://github.com/modelcontextprotocol/swift-sdk)
- Uses [Yams](https://github.com/jpsim/Yams) for YAML processing
- Command-line parsing powered by [swift-argument-parser](https://github.com/apple/swift-argument-parser)
