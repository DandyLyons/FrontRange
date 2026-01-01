# Testing the Automated Release Workflow

This document outlines how to test the new automated release workflow before merging the PR.

## Prerequisites

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name: "FrontRange Homebrew Formula Updater"
4. Select scope: `public_repo` (Full control of public repositories)
5. Click "Generate token" and **copy the token immediately**

### 2. Add Token to Repository Secrets

1. Go to FrontRange repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `FRONTRANGE_COMMITTER_TOKEN`
4. Value: Paste the token from step 1
5. Click "Add secret"

## Test Plan

### Test 1: Dry Run with Test Tag

1. **Merge this PR to main** (or test from the branch)

2. **Create a test tag** (will trigger the workflow):
   ```bash
   git checkout feat/automated-releases
   git tag v0.2.1-beta-test
   git push origin v0.2.1-beta-test
   ```

3. **Monitor the workflow**:
   - Go to Actions tab on GitHub
   - Watch the "Release" workflow run
   - Check each step completes successfully

4. **Verify outputs**:
   - [ ] GitHub release created at: https://github.com/DandyLyons/FrontRange/releases/tag/v0.2.1-beta-test
   - [ ] Release is marked as "Pre-release" (because it contains "beta")
   - [ ] Release has tarball attachment: `v0.2.1-beta-test.tar.gz`
   - [ ] Tarball contains both `fr` and `frontrange-mcp` binaries
   - [ ] Homebrew formula updated in DandyLyons/homebrew-frontrange

5. **Test Homebrew installation**:
   ```bash
   brew update
   brew upgrade frontrange
   # Or: brew install frontrange (if not already installed)

   # Verify both executables work
   fr --version
   frontrange-mcp --help
   ```

6. **Cleanup test release** (optional):
   ```bash
   # Delete the test release and tag
   gh release delete v0.2.1-beta-test --yes
   git push origin :refs/tags/v0.2.1-beta-test
   git tag -d v0.2.1-beta-test
   ```

### Test 2: Verify Universal Binary

Download the release tarball and verify it contains universal binaries:

```bash
# Download and extract
curl -L -o test.tar.gz https://github.com/DandyLyons/FrontRange/releases/download/v0.2.1-beta-test/v0.2.1-beta-test.tar.gz
tar -xzf test.tar.gz

# Check architecture
file fr
# Should show: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64:Mach-O 64-bit executable arm64]

file frontrange-mcp
# Should show: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64:Mach-O 64-bit executable arm64]

# Cleanup
rm -rf fr frontrange-mcp test.tar.gz
```

### Test 3: Full Release Cycle

Once tests pass, create a real release:

1. **Update version numbers** to v0.3.0-beta in:
   - `Sources/FrontRangeCLI/FrontRangeCLIEntry.swift`
   - `Sources/FrontRangeMCP/main.swift`

2. **Commit and push**:
   ```bash
   git add .
   git commit -m "Bump version to 0.3.0-beta"
   git push origin main
   ```

3. **Create release tag**:
   ```bash
   git tag v0.3.0-beta
   git push origin v0.3.0-beta
   ```

4. **Verify everything works** as in Test 1

## Troubleshooting

### Workflow fails with "permission denied"
- Check that `FRONTRANGE_COMMITTER_TOKEN` is set correctly in repository secrets
- Verify the token has `public_repo` scope

### Homebrew formula not updated
- Check the workflow logs for the "Update Homebrew formula" step
- Verify the `download-url` is correct in release.yml
- Check that the homebrew-frontrange repository is accessible

### Build fails
- Check Swift version matches (6.2)
- Verify all dependencies are accessible
- Check the GitHub Actions runner has sufficient resources

### Universal binary not created
- Verify the build command includes both architectures: `--arch arm64 --arch x86_64`
- Check that the build completed successfully before archiving

## Success Criteria

- [ ] Workflow completes without errors
- [ ] GitHub release is created with correct metadata
- [ ] Pre-release flag set correctly for beta versions
- [ ] Tarball contains both executables
- [ ] Both executables are universal binaries (arm64 + x86_64)
- [ ] Homebrew formula automatically updated with correct URL and SHA256
- [ ] `brew install frontrange` works on both Intel and Apple Silicon Macs
- [ ] Installed executables run correctly and show correct version
