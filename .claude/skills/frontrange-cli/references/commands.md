# FrontRange CLI Command Reference

Complete reference for all `fr` commands with detailed options and flags.

## Table of Contents

- [get - Retrieve front matter values](#get---retrieve-front-matter-values)
- [set - Modify front matter values](#set---modify-front-matter-values)
- [has - Check if a key exists](#has---check-if-a-key-exists)
- [list - List all front matter keys](#list---list-all-front-matter-keys)
- [remove - Delete front matter keys](#remove---delete-front-matter-keys)
- [rename - Rename front matter keys](#rename---rename-front-matter-keys)
- [sort-keys - Alphabetize front matter keys](#sort-keys---alphabetize-front-matter-keys)
- [lines - Get line information](#lines---get-line-information)
- [dump - Output entire front matter](#dump---output-entire-front-matter)
- [search - Query files by front matter](#search---query-files-by-front-matter)
- [replace - Replace entire front matter](#replace---replace-entire-front-matter)
- [Global Options](#global-options)

---

## get - Retrieve front matter values

Get a specific key's value from files or directories.

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

---

## set - Modify front matter values

Set or update a key's value in files or directories.

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

**Options:**
- `--key` / `-k`: The front matter key to set (required)
- `--value` / `-v`: The value to set (required)
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## has - Check if a key exists

Check whether files contain a specific front matter key.

```bash
# Check single file
fr has --key author post.md

# Check directory (non-recursive)
fr has --key draft posts/

# Check recursively
fr has --key category content/ -r
```

**Options:**
- `--key` / `-k`: The front matter key to check for (required)
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## list - List all front matter keys

Display all keys present in files' front matter.

```bash
# List keys in one file
fr list post.md

# List from directory
fr list posts/

# List recursively from directory tree
fr list content/ --recursive --format json
```

**Options:**
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--format` / `-f`: Output format (yaml, json, plainString)
- `--debug` / `-d`: Enable debug output

---

## remove - Delete front matter keys

Remove a key from front matter in files or directories.

```bash
# Remove from single file
fr remove --key temporary post.md

# Remove from directory (non-recursive)
fr remove --key draft published/

# Remove recursively
fr remove --key deprecated content/ -r
```

**Warning:** This modifies files. The key is permanently removed.

**Options:**
- `--key` / `-k`: The front matter key to remove (required)
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## rename - Rename front matter keys

Change a key's name while preserving its value.

```bash
# Rename in single file
fr rename --old-key author --new-key authors post.md

# Rename in directory
fr rename --old-key category --new-key categories posts/

# Rename recursively
fr rename --old-key tag --new-key tags content/ -r
```

**Options:**
- `--old-key`: The current key name (required)
- `--new-key`: The new key name (required)
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## sort-keys - Alphabetize front matter keys

Sort all keys in front matter alphabetically.

```bash
# Sort a single file
fr sort-keys post.md

# Sort all files in directory (non-recursive)
fr sort-keys posts/

# Sort recursively
fr sort-keys content/ --recursive
```

**Options:**
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## lines - Get line information

Show line numbers and ranges for front matter.

```bash
# Get front matter line range for file
fr lines post.md

# Get for all files in directory
fr lines posts/ -r
```

Useful for debugging or integration with other tools.

**Options:**
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output

---

## dump - Output entire front matter

Dump the complete front matter from files in various formats.

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
- `--debug` / `-d`: Enable debug output
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

---

## search - Query files by front matter

**Most powerful command** - Search for files matching JMESPath expressions.

**ALWAYS RECURSIVE** - no flag needed.

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

**Options:**
- Query expression: JMESPath expression (required, first positional argument)
- Path argument: Directory to search (required, second positional argument)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--format` / `-f`: Output format (yaml, json, plainString)
- `--debug` / `-d`: Enable debug output

**Note:** Search is ALWAYS recursive when given a directory.

---

## replace - Replace entire front matter

**DESTRUCTIVE** - Replace the complete front matter with new structured data.

**IMPORTANT:** This command prompts for confirmation before making changes.

**Input Methods:**

You must provide data using ONE of these options:
- `--data`: Inline data string
- `--from-file`: Read from a file

**Supported Formats:**
- `json`: JavaScript Object Notation
- `yaml`: YAML Ain't Markup Language
- `plist`: Apple PropertyList XML

**Validation:**
Front matter must be a dictionary/mapping. Arrays and scalars are rejected.

```bash
# Replace with inline JSON
fr replace post.md --data '{"title": "New Title", "draft": false}' --format json

# Replace from YAML file
fr replace post.md --from-file new-metadata.yaml --format yaml

# Replace from plist file
fr replace post.md --from-file config.plist --format plist

# Process multiple files (prompted once per file)
fr replace post1.md post2.md --data '{"status": "published"}' --format json

# Process directory recursively
fr replace posts/ -r --from-file standard-metadata.yaml --format yaml
```

**Options:**
- Path arguments: File(s) and/or directory(ies) to process (required)
- `--data`: Inline data string (mutually exclusive with --from-file)
- `--from-file`: Path to file containing data (mutually exclusive with --data)
- `--format` / `-f`: Data format - json (default), yaml, or plist
- `--recursive` / `-r`: Recursively process directories (default: false)
- `--extensions` / `-e`: File extensions to process (default: md,markdown,yml,yaml)
- `--debug` / `-d`: Enable debug output
- Alias: `r`

**Confirmation:**
The command prompts for confirmation (y/n) before replacing each file. This prevents accidental data loss.

**Use Cases:**
- Standardize front matter across multiple files
- Migrate from one schema to another
- Bulk reset metadata
- Apply template front matter
- Convert between data formats

**Safety:**
- Always use version control (git)
- Test on a copy first
- The command shows the file path and waits for confirmation
- Type 'y' or 'yes' to proceed, anything else cancels

**Examples:**

```bash
# Create standardized front matter template
cat > template.json <<EOF
{
  "draft": false,
  "published": true,
  "author": "Your Name",
  "date": "2025-12-11",
  "tags": []
}
EOF

# Apply to all posts
fr replace posts/ -r --from-file template.json --format json

# Replace with YAML (useful for complex structures)
cat > metadata.yaml <<EOF
title: New Post
draft: false
tags:
  - tutorial
  - swift
metadata:
  author: Jane Doe
  category: Technical
EOF

fr replace post.md --from-file metadata.yaml --format yaml

# One-liner JSON replacement
fr replace article.md --data '{"title": "Updated", "status": "review"}' --format json
```

**Validation Errors:**

```bash
# Array rejected
$ fr replace post.md --data '["tag1", "tag2"]' --format json
Error: Front matter must be a dictionary/mapping, not a array/sequence

# Scalar rejected
$ fr replace post.md --data '"just a string"' --format json
Error: Front matter must be a dictionary/mapping, not a scalar/primitive value

# Both input options
$ fr replace post.md --data '{}' --from-file file.json
Error: Cannot use both --data and --from-file
```

**Comparison with Other Commands:**

| Command | Purpose | Scope |
|---------|---------|-------|
| `set` | Set/update ONE key | Single key-value pair |
| `replace` | Replace ENTIRE front matter | Destructive, all keys |
| `remove` | Delete ONE key | Single key removal |

Use `replace` when you need to completely overwrite all front matter. Use `set` for updating individual keys.

---

## Global Options

Options available across commands:

- **Path arguments:** File(s) and/or directory(ies) to process (required for most commands)
- `--recursive` / `-r`: Recursively process directories (default: false, **except search which is always recursive**)
- `--extensions` / `-e`: File extensions to process (default: `md,markdown,yml,yaml`)
- `--format` / `-f`: Output format - `yaml`, `json`, or `plainString`
- `--debug` / `-d`: Enable debug output for troubleshooting
