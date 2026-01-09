# FrontRange CLI Troubleshooting & Advanced Usage

Troubleshooting guide and advanced usage patterns for the FrontRange CLI.

## Table of Contents

- [Important Considerations](#important-considerations)
- [Troubleshooting](#troubleshooting)
- [Development vs Production](#development-vs-production)

---

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

---

## Troubleshooting

### Command not found

Make sure you're in the FrontRange project directory or `fr` is installed globally. Use:
```bash
fr <command>
```

If developing, use:
```bash
swift run fr <command>
```

### Not processing subdirectories

Remember:
- Most commands need `--recursive` / `-r` flag for subdirectories
- Search command is ALWAYS recursive

```bash
# Get from subdirectories - needs -r
fr get --key title posts/ -r

# Search in subdirectories - always recursive
fr search 'draft == `true`' posts/
```

### Wrong file types processed

Check your `--extensions` option:
```bash
# See what extensions are being used
fr get --key title posts/ -r --debug

# Override extensions
fr get --key title posts/ -r --extensions md
```

### JMESPath syntax errors

Common issues:
- Always use single quotes around the expression
- Always use backticks around literals
- Check for matching quotes and backticks
- Use `--debug` flag to see parsing errors

**Debugging:**
```bash
# Use debug flag to see what's happening
fr search 'draft == `true`' posts/ --debug

# Test simple queries first
fr search 'draft' posts/  # Just check if key exists

# Build up complexity
fr search 'draft == `true`' posts/
fr search 'draft == `true` && published == `false`' posts/
```

### File not modified

Checklist:
- Check that files have front matter delimiters (`---`)
- Verify file paths are correct
- Ensure you have write permissions
- Use `--debug` to see what's happening

```bash
# Check if file has front matter
fr list problem-file.md

# Check if specific key exists
fr has --key title problem-file.md

# Try with debug output
fr set --key title --value "Test" problem-file.md --debug
```

### Missing key errors

When a key doesn't exist, commands will error:

```bash
$ fr get --key nonexistent post.md
Error: Key 'nonexistent' not found in frontmatter.
```

**Solutions:**

1. Check if key exists first:
   ```bash
   fr has --key tags post.md && fr get --key tags post.md
   ```

2. Use search to find files that have the key:
   ```bash
   fr search 'tags' posts/
   ```

3. Suppress errors if expected:
   ```bash
   fr get --key tags posts/ -r 2>/dev/null
   ```

### Performance issues with large directories

For very large directories (1000+ files):

```bash
# Use extension filtering to reduce files processed
fr search 'draft' . --extensions md

# Process subdirectories separately instead of from root
fr get --key title content/posts/ -r
fr get --key title content/pages/ -r

# Use xargs with batching for large result sets
fr search 'draft == `true`' . | xargs -n 100 fr set --key reviewed --value true
```

### Paths with spaces or special characters

Use proper quoting:

```bash
# Use quotes around paths with spaces
fr get --key title "My Documents/posts/article.md"

# In loops, use quotes around variables
fr search 'draft' . | while read -r file; do
  fr get --key title "$file"  # Quotes around $file
done

# With xargs, use -I flag
fr search 'draft' . | xargs -I {} fr get --key title "{}"
```

---

## Development vs Production

### During Development

When developing FrontRange itself, use `swift run`:

```bash
# Run from project directory
swift run fr get --key title posts/

# Build and run tests
swift build
swift test
```

### Production/CI Usage

For production or CI environments, build a release binary:

```bash
# Build release binary (optimized)
swift build -c release

# Use binary directly (faster, no compilation delay)
.build/release/fr get --key title posts/ -r

# Install globally (optional)
cp .build/release/fr /usr/local/bin/fr
```

### Performance Comparison

```bash
# Development mode (compiles on each run)
time swift run fr search 'draft' posts/
# ~2-3 seconds (includes compilation)

# Release binary (no compilation)
time .build/release/fr search 'draft' posts/
# ~0.1-0.2 seconds (just execution)
```

For scripts or CI, always use the release binary.
