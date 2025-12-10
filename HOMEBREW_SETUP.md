# Homebrew Beta Release Setup Guide

This guide explains how to set up and maintain the Homebrew tap for FrontRange.

## Overview

FrontRange uses a **custom Homebrew tap** for beta releases. This allows users to install the tools via Homebrew before submitting to the main Homebrew repository.

- **Tap Repository**: `homebrew-frontrange` (to be created in the DandyLyons GitHub organization)
- **Installation Command**: `brew install dandylyons/frontrange/frontrange`
- **Current Version**: `0.1.0-beta`
- **Installed Tools**:
  - `fr` - CLI tool for managing front matter
  - `frontrange-mcp` - Model Context Protocol server

## Initial Setup

### Step 1: Create the Tap Repository

1. Create a new GitHub repository named `homebrew-frontrange` in the DandyLyons organization
   - Repository name MUST be `homebrew-frontrange` (Homebrew naming convention)
   - Make it public
   - Add a description: "Homebrew tap for FrontRange tools"
   - Initialize with a README

2. Clone the tap repository locally:
   ```bash
   git clone https://github.com/DandyLyons/homebrew-frontrange.git
   cd homebrew-frontrange
   ```

3. Create the Formula directory structure:
   ```bash
   mkdir -p Formula
   ```

4. Copy the formula from this repository:
   ```bash
   cp /path/to/FrontRange/Formula/frontrange.rb Formula/frontrange.rb
   ```

### Step 2: Create a GitHub Release

In the main FrontRange repository:

1. Ensure all changes are committed and pushed to main:
   ```bash
   git add .
   git commit -m "Prepare for v0.1.0-beta release"
   git push origin main
   ```

2. Create and push the release tag:
   ```bash
   git tag -a v0.1.0-beta -m "Beta release v0.1.0-beta"
   git push origin v0.1.0-beta
   ```

3. Create a GitHub release:
   - Go to https://github.com/DandyLyons/FrontRange/releases/new
   - Tag: `v0.1.0-beta`
   - Title: `v0.1.0-beta`
   - Description: Include release notes (features, changes, known issues)
   - Mark as "This is a pre-release" (beta checkbox)
   - Publish release

4. Calculate the SHA256 of the release tarball:
   ```bash
   # Download the release tarball
   curl -L https://github.com/DandyLyons/FrontRange/archive/refs/tags/v0.1.0-beta.tar.gz -o frontrange.tar.gz

   # Calculate SHA256
   shasum -a 256 frontrange.tar.gz
   ```

5. Update the formula with the SHA256:
   - Edit `homebrew-frontrange/Formula/frontrange.rb`
   - Replace the empty `sha256 ""` with the calculated hash
   - Example: `sha256 "abc123..."`

6. Commit and push the formula:
   ```bash
   cd homebrew-frontrange
   git add Formula/frontrange.rb
   git commit -m "Add frontrange v0.1.0-beta formula"
   git push origin main
   ```

### Step 3: Test the Installation

1. Tap the repository locally:
   ```bash
   brew tap dandylyons/frontrange
   ```

2. Install FrontRange:
   ```bash
   brew install dandylyons/frontrange/frontrange
   ```

3. Verify the installation:
   ```bash
   fr --version          # Should output: 0.1.0-beta
   frontrange-mcp        # Should start the MCP server

   # Test basic functionality
   echo -e "---\ntitle: Test\n---\nContent" | fr get --key title
   ```

4. Run Homebrew's audit:
   ```bash
   brew audit --strict dandylyons/frontrange/frontrange
   ```

## Updating for New Releases

When releasing a new version (e.g., `0.1.0-beta.2` or `0.2.0`):

1. Update version strings in FrontRange repository:
   - `Sources/FrontRangeCLI/FrontRangeCLIEntry.swift`
   - `Sources/FrontRangeMCP/main.swift`

2. Create a new git tag and GitHub release (follow Step 2 above)

3. Update the formula in `homebrew-frontrange`:
   ```bash
   cd homebrew-frontrange
   # Edit Formula/frontrange.rb:
   # - Update the URL with new tag
   # - Calculate and update sha256
   # - Update version number in tests

   git add Formula/frontrange.rb
   git commit -m "Update to v0.2.0"
   git push origin main
   ```

4. Users update with:
   ```bash
   brew update
   brew upgrade dandylyons/frontrange/frontrange
   ```

## Troubleshooting

### Common Issues

1. **SHA256 mismatch error**:
   - Recalculate the SHA256 using the command in Step 2.4
   - Ensure you're downloading the exact tarball URL specified in the formula

2. **Build failures**:
   - Check that Xcode and Swift are properly installed
   - Verify the Swift version matches requirements (6.2+)
   - Check build logs: `brew install --verbose dandylyons/frontrange/frontrange`

3. **Formula audit failures**:
   - Run `brew audit --strict` to see specific issues
   - Common issues: missing license, incorrect homepage, SHA256 mismatch

### Testing Locally

To test formula changes before pushing:

```bash
# Edit the formula
vim Formula/frontrange.rb

# Test install from local formula
brew install --build-from-source Formula/frontrange.rb

# Uninstall for clean testing
brew uninstall frontrange
```

## Transition to Main Homebrew

Once the beta period is complete and the tool is stable:

1. Update to a stable version (e.g., `1.0.0`)
2. Submit a PR to `Homebrew/homebrew-core`:
   - Follow Homebrew contribution guidelines
   - Formula will be reviewed by Homebrew maintainers
   - Users can then install with just `brew install frontrange`

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Swift Formula Examples](https://github.com/Homebrew/homebrew-core/search?q=language%3ARuby+swift+build)
- [FrontRange Repository](https://github.com/DandyLyons/FrontRange)

## Files Reference

- **Formula file**: `homebrew-frontrange/Formula/frontrange.rb`
- **Template**: `FrontRange/Formula/frontrange.rb` (this repository)
- **CLI version**: `FrontRange/Sources/FrontRangeCLI/FrontRangeCLIEntry.swift:18`
- **MCP version**: `FrontRange/Sources/FrontRangeMCP/main.swift:28`
