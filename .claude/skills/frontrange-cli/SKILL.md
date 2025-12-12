---
name: frontrange-cli
description: Expert guidance for using the FrontRange CLI (fr command) to manage YAML front matter in text documents. Use when working with front-mattered files, YAML metadata, blog posts, markdown with front matter, or when the user mentions 'fr' commands.
---

# FrontRange CLI Expert

This Skill provides comprehensive guidance on using the **FrontRange CLI (`fr`)** tool for managing YAML front matter in text documents.

## When to Use This Skill

Invoke this Skill when:
- User wants to read, modify, or search YAML front matter in files
- Working with markdown files, blog posts, or documents with metadata headers
- User mentions the `fr` command or FrontRange CLI
- Tasks involve bulk operations on front matter across multiple files
- Need to query or filter files based on front matter properties

## Core Concepts

### What is Front Matter?

Front matter is YAML metadata at the beginning of a text file, enclosed by `---` delimiters:

```markdown
---
title: My Blog Post
draft: true
tags: ["swift", "tutorial"]
date: 2025-01-15
---

# Blog Post Content

This is the body of the document...
```

## How to Invoke the CLI

The `fr` command can be used in two ways:

1. **Installed globally** (recommended for regular use):
    ```bash
    fr <command>
    ```
This guide assumes fr is installed and available in your PATH.

2. During development (from the FrontRange project directory):
```bash
swift run fr <command>
```
DO NOT USE `swift run fr` unless developing or testing FrontRange itself.

## Directory and Recursive Processing

**CRITICAL:** The `fr` CLI has powerful directory processing capabilities that work differently for different commands.

### Most Commands: Explicit Recursive Flag

For most commands (`get`, `set`, `has`, `list`, `remove`, `rename`, `sort-keys`, `lines`), you can provide:

1. **Individual files:**
   ```bash
   fr get --key title post.md
   ```

2. **Directories (non-recursive by default):**
   ```bash
   # Processes only files directly in the posts/ directory
   fr get --key draft posts/
   ```

3. **Directories with `--recursive` / `-r` flag:**
   ```bash
   # Recursively processes ALL files in posts/ and subdirectories
   fr get --key draft --recursive posts/

   # Short form
   fr get --key draft -r posts/
   ```

4. **Multiple paths:**
   ```bash
   # Mix files and directories
   fr set --key draft --value false post1.md posts/ drafts/ -r
   ```

### Search Command: Always Recursive

The `search` command **ALWAYS searches recursively** when given a directory - no flag needed:

```bash
# Automatically searches recursively through all subdirectories
fr search 'draft == `true`' ./posts

# Same behavior - always recursive
fr search 'published == `false`' .
```

### Extension Filtering

By default, `fr` processes these extensions: `md`, `markdown`, `yml`, `yaml`

**Override with `--extensions` / `-e`:**

```bash
# Process only markdown files
fr get --key title posts/ -r --extensions md

# Process multiple custom extensions
fr list docs/ --extensions txt,md,rst

# Process all files (empty string)
fr search 'draft' . --extensions ""
```

**Extension filtering applies to ALL commands**, including search.

### Complete Directory Processing Examples

```bash
# Get all drafts from posts directory (non-recursive)
fr get --key draft posts/

# Get all drafts from posts directory and all subdirectories
fr get --key draft posts/ --recursive

# Search entire project recursively (search is always recursive)
fr search 'draft == `true`' .

# Set value on all markdown files in content/ recursively
fr set --key reviewed --value true content/ -r --extensions md

# Process mixed paths: specific files + directories
fr list post1.md posts/ drafts/ -r

# Recursive operation with custom extensions
fr sort-keys docs/ -r --extensions md,txt,rst
```

## Available Commands

### 1. **get** - Retrieve front matter values

Get a specific key's value from files or directories:

```bash
# Get from a single file
fr get --key title post.md

# Get from all files in a directory (non-recursive)
fr get --key draft posts/

# Get from directory tree recursively
fr get --key author posts/ --recursive

# Multiple paths (files and directories)
fr get --key tags post.md drafts/ published/ -r

# Format output as JSON
fr get --key tags posts/ -r --format json
```

**Options:**
- `--key` / `-k`: The front matter key to retrieve (required)
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--format` / `-f`: Output format (yaml, json, plainString)
- `--debug` / `-d`: Enable debug output

### 2. **set** - Modify front matter values

Set or update a key's value in files or directories:

```bash
# Set in a single file
fr set --key title --value "New Title" post.md

# Set in all files in a directory (non-recursive)
fr set --key draft --value false posts/

# Set recursively in directory tree
fr set --key published --value true posts/ --recursive

# Bulk update across multiple locations
fr set --key reviewed --value true post1.md drafts/ published/ -r
```

**Important:** Values are provided as strings and parsed as YAML scalars.

### 3. **has** - Check if a key exists

Check whether files contain a specific front matter key:

```bash
# Check single file
fr has --key author post.md

# Check directory (non-recursive)
fr has --key draft posts/

# Check recursively
fr has --key category content/ -r
```

### 4. **list** - List all front matter keys

Display all keys present in files' front matter:

```bash
# List keys in one file
fr list post.md

# List from directory
fr list posts/

# List recursively from directory tree
fr list content/ --recursive --format json
```

### 5. **remove** - Delete front matter keys

Remove a key from front matter in files or directories:

```bash
# Remove from single file
fr remove --key temporary post.md

# Remove from directory (non-recursive)
fr remove --key draft published/

# Remove recursively
fr remove --key deprecated content/ -r
```

**Warning:** This modifies files. The key is permanently removed.

### 6. **rename** - Rename front matter keys

Change a key's name while preserving its value:

```bash
# Rename in single file
fr rename --old-key author --new-key authors post.md

# Rename in directory
fr rename --old-key category --new-key categories posts/

# Rename recursively
fr rename --old-key tag --new-key tags content/ -r
```

### 7. **sort-keys** - Alphabetize front matter keys

Sort all keys in front matter alphabetically:

```bash
# Sort a single file
fr sort-keys post.md

# Sort all files in directory (non-recursive)
fr sort-keys posts/

# Sort recursively
fr sort-keys content/ --recursive
```

### 8. **lines** - Get line information

Show line numbers and ranges for front matter:

```bash
# Get front matter line range for file
fr lines post.md

# Get for all files in directory
fr lines posts/ -r
```

Useful for debugging or integration with other tools.

### 9. **dump** - Output entire front matter

Dump the complete front matter from files in various formats:

```bash
# Dump single file as JSON (default)
fr dump post.md

# Dump with YAML format
fr dump post.md --format yaml

# Dump with --- delimiters included
fr dump post.md --format yaml --include-delimiters

# Dump as PropertyList XML
fr dump post.md --format plist

# Dump as raw YAML (alias for yaml)
fr dump post.md --format raw

# Dump multiple files
fr dump posts/ --format json

# Dump recursively from directory tree
fr dump posts/ -r --format yaml

# Combine with custom extensions
fr dump content/ -r --format plist --extensions md,txt
```

**Options:**
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--format` / `-f`: Output format (json, yaml, raw, plist) - default: json
- `--include-delimiters`: Add --- delimiters to YAML/raw output (default: false)
- Alias: `d`

**Debug output:** Set the `FRONTRANGE_DEBUG` environment variable to enable debug output.

**Use Cases:**
- Export front matter for external processing
- Convert between formats (YAML to JSON, JSON to plist)
- Extract all metadata for analysis or migration
- Generate PropertyList files for macOS/iOS integration
- Bulk export of front matter data

**Format Details:**
- **json**: Pretty-printed JSON with sorted keys
- **yaml**: Clean YAML output
- **raw**: Alias for yaml format
- **plist**: Apple PropertyList XML format

**Examples:**

```bash
# Export all post metadata as JSON for processing
fr dump posts/ -r --format json > all-metadata.json

# Convert front matter to plist for macOS app
fr dump config.md --format plist > config.plist

# Get YAML with delimiters (ready to paste into file)
fr dump template.md --format yaml --include-delimiters

# Bulk dump for migration
for file in *.md; do
  fr dump "$file" --format json > "${file%.md}.json"
done
```

### 10. **search** - Query files by front matter

**Most powerful command** - Search for files matching JMESPath expressions.

**ALWAYS RECURSIVE** - no flag needed:

```bash
# Find all draft posts (searches recursively automatically)
fr search 'draft == `true`' ./posts

# Search entire project
fr search 'contains(tags, `"swift"`)' .

# Complex queries
fr search 'draft == `false` && contains(tags, `"tutorial"`)' content/

# Control extensions
fr search 'published == `true`' . --extensions md

# Format results
fr search 'author == `"Jane"`' . --format json
```

**Critical JMESPath Syntax Rules:**

1. **ALWAYS wrap the entire expression in SINGLE QUOTES** (to prevent shell interpretation)
2. **ALWAYS use BACKTICKS for ALL literals:**
   - Booleans: `` `true` ``, `` `false` ``
   - Strings: `` `"text"` ``
   - Numbers: `` `42` ``, `` `3.14` ``
   - Null: `` `null` ``

**Common JMESPath Patterns:**

```bash
# Equality
'draft == `true`'
'status == `"published"`'

# Contains (for arrays)
'contains(tags, `"swift"`)'

# Boolean logic
'draft == `false` && featured == `true`'
'status == `"draft"` || status == `"review"`'

# Comparisons
'views > `1000`'
'rating >= `4.5`'
```

**Search Output:**

Outputs file paths (one per line). Progress messages go to stderr and won't interfere with piping:
```bash
$ fr search 'draft == `true`' ./posts
Processing batch 1/4...  # stderr - safe to ignore
/path/to/file1.md        # stdout - piped
/path/to/file2.md        # stdout - piped
```

Suppress progress: `fr search 'draft' . 2>/dev/null`

## Bulk Operations with Piping

The `search` command outputs paths, enabling powerful bulk operations:

### Choosing the Right Approach

| Scenario | Use | Why |
|----------|-----|-----|
| <100 files, no spaces | `xargs` | Fast, simple |
| Paths with spaces | `while read` | Handles quoting |
| 100+ files | `while read` | Avoids arg limits |
| Multi-step operations | `while read` | Easier to debug |

### Using xargs

**CAUTION:** xargs has system argument limits (~4096) and fails with spaces in paths.

```bash
# Simple cases (few files, no spaces)
fr search 'draft == `true`' ./posts | xargs fr set --key draft --value false

# With spaces: use -I flag
fr search 'tags' . | xargs -I {} fr get --key tags "{}"

# Large operations: batch with -n
fr search 'tags' . | xargs -n 50 fr get --key tags
```

### Using while loops (Recommended)

**Handles spaces, special characters, and large file sets reliably:**

```bash
# Publish and date-stamp matching posts
fr search 'draft == `true`' ./posts | while read -r file; do
  fr set "$file" --key published --value true
  fr set "$file" --key date --value "$(date +%Y-%m-%d)"
done

# With error handling
fr search 'tags' . | while read -r file; do
  tags=$(fr get --key tags "$file" 2>&1)
  if [[ ! "$tags" =~ "not found" ]]; then
    echo "$file: $tags"
  fi
done
```

## Handling Missing Keys & Errors

Not all files have all keys. Commands output errors when keys are missing:

```bash
$ fr get --key tags post.md
Error: Key 'tags' not found in frontmatter.
```

**Strategies:**

1. **Filter with search first** (only processes files with the key):
   ```bash
   fr search 'tags' . | while read -r file; do
     fr get --key tags "$file"
   done
   ```

2. **Suppress expected errors:**
   ```bash
   fr get --key tags posts/ -r 2>/dev/null
   ```

3. **Check for errors in scripts:**
   ```bash
   tags=$(fr get --key tags "$file" 2>&1)
   if [[ ! "$tags" =~ "Error" ]]; then
     echo "$tags"
   fi
   ```

## Global Options Summary

Options available across commands:

- **Path arguments:** File(s) and/or directory(ies) to process (required for most commands)
- `--recursive` / `-r`: Recursively process directories (default: false, **except search which is always recursive**)
- `--extensions` / `-e`: File extensions to process (default: `md,markdown,yml,yaml`)
- `--format` / `-f`: Output format - `yaml`, `json`, or `plainString`
- `--debug` / `-d`: Enable debug output for troubleshooting

## Common Patterns & Recipes

### Publishing Workflow

```bash
# Find drafts ready to publish (recursive search)
fr search 'draft == `true` && ready == `true`' ./posts

# Publish them
fr search 'draft == `true` && ready == `true`' ./posts | while read -r file; do
  fr set "$file" --key draft --value false
  fr set "$file" --key published --value true
  fr set "$file" --key publishDate --value "$(date +%Y-%m-%d)"
done
```

### Content Auditing

```bash
# Get all authors from entire content tree
fr get --key author content/ -r --format json

# Count posts by status (search is always recursive)
fr search 'status == `"draft"`' posts | wc -l
fr search 'status == `"published"`' posts | wc -l

# List all unique tags across all posts
fr get --key tags posts/ -r --format json | jq -r '.[]' | sort -u
```

### Batch Updates

```bash
# Add a new key to all files recursively
fr set --key lastChecked --value "2025-12-10" posts/ -r

# Update all markdown files in content tree
fr set --key version --value "2.0" content/ -r --extensions md

# Rename keys across entire project
fr rename --old-key category --new-key categories . -r
```

### Cleanup Operations

```bash
# Remove deprecated keys (search is recursive)
fr search 'oldField' . | xargs fr remove --key oldField

# Sort keys in all files recursively
fr sort-keys content/ -r

# Remove temporary fields from drafts directory
fr remove --key temp drafts/ -r
```

### Working with Subdirectories

```bash
# Process specific subdirectory structure
fr set --key section --value "tutorials" content/tutorials/ -r
fr set --key section --value "guides" content/guides/ -r

# Search specific subtree
fr search 'featured == `true`' content/blog/

# Combine search with directory-specific updates
fr search 'draft == `false`' content/tutorials/ | \
  xargs fr set --key category --value "tutorial"
```

## Important Considerations

### 1. Directory Processing Modes

**Key Rule:** Most commands require `--recursive` for subdirectories, but **search is always recursive**.

```bash
# These are DIFFERENT:
fr get --key draft posts/          # Only direct children
fr get --key draft posts/ -r       # All subdirectories too

# Search is ALWAYS recursive (no flag needed or accepted)
fr search 'draft == `true`' posts/ # Searches all subdirectories
```

### 2. Extension Filtering

Default extensions are `md,markdown,yml,yaml`. To process other file types:

```bash
# Custom extensions
fr list docs/ -r --extensions txt,md,rst

# All files (use empty string)
fr search 'title' . --extensions ""
```

### 3. YAML Node Types

Internally, FrontRange works with `Yams.Node` types, not plain Swift dictionaries. The CLI handles this conversion, but be aware:

- Complex YAML structures (nested maps, arrays) are preserved
- Type information is maintained (strings vs numbers vs booleans)
- YAML comments and formatting may not be preserved after modification

### 4. File Modification

Commands like `set`, `remove`, `rename`, and `sort-keys` **modify files in place**. Always:
- Use version control (git)
- Test on sample files first
- Use `--debug` flag when unsure

### 5. JMESPath Shell Escaping

The single most common error is improper quoting. Remember:

**CORRECT:**
```bash
fr search 'draft == `true`' .
fr search 'contains(tags, `"swift"`)' posts/
```

**INCORRECT:**
```bash
fr search draft == `true` .           # Shell interprets backticks
fr search "draft == `true`" .         # Shell interprets backticks
fr search 'draft == true' .           # Missing backticks around literal
```

### 6. Development vs Production

During development, use `fr`. For production/CI:

```bash
# Build release binary
swift build -c release

# Use binary directly (faster)
.build/release/fr get --key title posts/ -r
```

## Troubleshooting

### Command not found

Make sure you're in the FrontRange project directory and use:
```bash
fr <command>
```

### Not processing subdirectories

Remember:
- Most commands need `--recursive` / `-r` flag for subdirectories
- Search command is ALWAYS recursive

### Wrong file types processed

Check your `--extensions` option:
```bash
# See what extensions are being used
fr get --key title posts/ -r --debug

# Override extensions
fr get --key title posts/ -r --extensions md
```

### JMESPath syntax errors

- Always use single quotes around the expression
- Always use backticks around literals
- Check for matching quotes and backticks
- Use `--debug` flag to see parsing errors

### File not modified

- Check that files have front matter delimiters (`---`)
- Verify file paths are correct
- Ensure you have write permissions
- Use `--debug` to see what's happening

## Advanced: Complex Scripts for Structured Data

**For operations requiring precise control over many files with special characters in paths:**

Create standalone bash scripts for maintainability:

```bash
#!/bin/bash
# Save as extract_tags.sh
echo "{"

books=(
  "/path/with spaces/Book 1.md"
  "/path/with (parens)/Book 2.md"
)

total=${#books[@]}
count=0

for book_path in "${books[@]}"; do
  count=$((count + 1))
  if [ -f "$book_path" ]; then
    book_name=$(basename "$book_path" .md)
    tags=$(fr get --key tags "$book_path" 2>&1)

    if [[ ! "$tags" =~ "not found" ]] && [[ ! "$tags" =~ "Error" ]]; then
      echo -n "  \"$book_name\": $tags"
      [ $count -lt $total ] && echo "," || echo ""
    fi
  fi
done

echo "}"
```

Run: `chmod +x extract_tags.sh && ./extract_tags.sh > output.json`

**When to use scripts vs one-liners:**
- Repeatable operations → Script file
- Paths with spaces/special chars → Script file
- JSON/structured output → Script file
- One-time quick task → Command-line

## Testing Your Commands

Before bulk operations, test on a sample directory:

```bash
# 1. Create test directory structure
mkdir -p test-dir/subdir
cat > test-dir/post1.md << 'EOF'
---
title: Post 1
draft: true
---
Content 1
EOF

cat > test-dir/subdir/post2.md << 'EOF'
---
title: Post 2
draft: true
---
Content 2
EOF

# 2. Test non-recursive (only post1.md)
fr get --key draft test-dir/

# 3. Test recursive (both files)
fr get --key draft test-dir/ --recursive

# 4. Test search (always recursive)
fr search 'draft == `true`' test-dir/

# 5. Test modification
fr set --key draft --value false test-dir/ -r

# 6. Verify
fr get --key draft test-dir/ -r

# 7. Clean up
rm -rf test-dir/
```

## Examples

### Complete Directory-Aware Workflow

```bash
# Step 1: Understand directory structure
find posts -type f -name "*.md" | head -10

# Step 2: Search recursively for drafts (search is always recursive)
fr search 'draft == `true`' ./posts

# Step 3: Check which drafts are in subdirectories
fr search 'draft == `true` && ready == `true`' ./posts --format json

# Step 4: Review front matter in subdirectories
fr list posts/tutorials/ -r

# Step 5: Publish ready posts across all subdirectories
fr search 'draft == `true` && ready == `true`' ./posts | while read -r file; do
  echo "Publishing: $file"
  fr set "$file" --key draft --value false
  fr set "$file" --key published --value true
  fr set "$file" --key date --value "$(date +%Y-%m-%d)"
  fr remove "$file" --key ready
done

# Step 6: Verify changes across entire tree
fr search 'published == `true`' ./posts | tail -5
fr get --key published posts/ -r | grep -c true
```

### Organizing Content by Directory

```bash
# Set category based on directory location
fr set --key category --value "tutorial" content/tutorials/ -r
fr set --key category --value "guide" content/guides/ -r
fr set --key category --value "blog" content/blog/ -r

# Find mismatched categories
fr search 'category != `"tutorial"`' content/tutorials/
fr search 'category != `"guide"`' content/guides/

# Add section metadata to all files in each section
for section in intro advanced reference; do
  fr set --key section --value "$section" "content/$section/" -r
done
```

## Summary

The FrontRange CLI provides a complete toolkit for managing YAML front matter with powerful directory processing:

**Directory Processing:**
- Most commands: Use `--recursive` / `-r` for subdirectories
- Search command: **Always recursive** automatically
- Extension filtering: `--extensions` controls which files to process

**Command Categories:**
- **Read operations**: `get`, `has`, `list`, `lines`
- **Write operations**: `set`, `remove`, `rename`, `sort-keys`
- **Query operations**: `search` with JMESPath (always recursive)
- **Bulk operations**: Pipe search results to other commands

**Key principle:** The `search` command finds files recursively, and you pipe those paths to other `fr` commands for bulk operations.

For more details, see:
- [README.md](../../README.md) - Project overview
- [CLAUDE.md](../../CLAUDE.md) - Developer guide
- [GlobalOptions.swift](../../Sources/FrontRangeCLI/GlobalOptions.swift) - Directory processing implementation
- [Search.swift](../../Sources/FrontRangeCLI/Commands/Search.swift) - Search command implementation
