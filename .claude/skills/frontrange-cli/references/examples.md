# FrontRange CLI Patterns & Examples

Practical patterns, recipes, and workflows for using the FrontRange CLI effectively.

## Table of Contents

- [Bulk Operations with Piping](#bulk-operations-with-piping)
- [Handling Missing Keys & Errors](#handling-missing-keys--errors)
- [Common Patterns & Recipes](#common-patterns--recipes)
- [Advanced Scripts for Structured Data](#advanced-scripts-for-structured-data)
- [Testing Commands](#testing-commands)
- [Complete Workflows](#complete-workflows)

---

## Bulk Operations with Piping

The `search` command outputs paths, enabling powerful bulk operations.

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

---

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

---

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

---

## Advanced Scripts for Structured Data

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

---

## Testing Commands

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

---

## Complete Workflows

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

### Piping Examples

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
