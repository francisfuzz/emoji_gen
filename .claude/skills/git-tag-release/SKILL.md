---
name: git-tag-release
description: Automate Git tagging for releases by updating Cargo.toml, creating tags, and triggering CI deployment. Use when the user mentions "tag release", "create tag", "tag version", or wants to trigger a release.
allowed-tools: Bash, Read, Edit
---

# Git Tag Release for emoji_gen

This Skill automates the Git tagging process for emoji_gen releases. It updates metadata (Cargo.toml, Cargo.lock), creates an annotated tag, and pushes everything to trigger the automated release workflow.

## Overview

When you push a version tag (format: `vX.Y.Z`), the GitHub Actions workflow automatically:
- Builds binaries for all platforms (Linux x86_64/ARM64, macOS Intel/Apple Silicon, Windows x86_64)
- Publishes multi-platform Docker images to `ghcr.io/francisfuzz/emoji_gen`
- Creates GitHub Release with all artifacts and checksums
- Tags Docker images with version and `latest`

## Pre-Release Requirements

Before tagging, ensure:
1. All changes are committed and pushed to main
2. Tests pass: `./docker-dev.sh test`
3. Clippy passes: `./docker-dev.sh clippy`
4. You know what version number to use

## Automated Tagging Process

This skill performs these steps in sequence:

### 1. Analyze Commits for Version Bump

Determine the appropriate version bump by analyzing commits since the last tag:

```bash
# Get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

# Show commits since last tag
if [ "$LAST_TAG" = "none" ]; then
  git log --oneline
else
  git log ${LAST_TAG}..HEAD --oneline
fi
```

**Decision logic:**
- Has `BREAKING CHANGE:` or `!` in commits → MAJOR bump (X.0.0)
- Has `feat:` commits → MINOR bump (0.X.0)
- Only `fix:`, `docs:`, `build:`, etc. → PATCH bump (0.0.X)

### 2. Update Cargo.toml Version

Use the Edit tool to update the version field in Cargo.toml:

```toml
# Change from:
version = "0.1.2"

# To:
version = "0.2.0"
```

### 3. Update Cargo.lock

Run cargo build to update Cargo.lock with the new version:

```bash
cargo build --release
```

### 4. Commit Version Bump

Create a commit following Conventional Commits format:

```bash
git add Cargo.toml Cargo.lock
git commit -m "$(cat <<'EOF'
chore: bump version to X.Y.Z

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### 5. Create Annotated Tag

Create an annotated tag (required for the release workflow):

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

### 6. Push Commit and Tag (Performant)

Push both the commit and tag in parallel for maximum performance:

```bash
# Push commit and tag together (single network round-trip)
git push origin main && git push origin vX.Y.Z
```

This triggers the release workflow immediately.

### 7. Monitor Release Progress

Watch the GitHub Actions workflow:

```bash
# Watch workflow in terminal
gh run watch

# Or open in browser
gh run view --web
```

## Complete Automated Workflow Example

```bash
# 1. Get current version
CURRENT_VERSION=$(grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
echo "Current version: $CURRENT_VERSION"

# 2. Analyze commits and suggest version
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
git log ${LAST_TAG}..HEAD --oneline

# 3. Determine new version (example: 0.1.2 → 0.2.0)
NEW_VERSION="0.2.0"

# 4. Update Cargo.toml using Edit tool
# Change: version = "0.1.2"
# To:     version = "0.2.0"

# 5. Update Cargo.lock
cargo build --release

# 6. Commit version bump
git add Cargo.toml Cargo.lock
git commit -m "$(cat <<'EOF'
chore: bump version to 0.2.0

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# 7. Create annotated tag
git tag -a v0.2.0 -m "Release v0.2.0"

# 8. Push commit and tag (performant - single operation)
git push origin main && git push origin v0.2.0

# 9. Monitor release
gh run watch
```

## Version Bump Helper

Use this script to determine the version bump:

```bash
#!/bin/bash
# Analyze commits and suggest version bump

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
CURRENT_VERSION=$(grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/')

echo "Current version: $CURRENT_VERSION"
echo "Last tag: $LAST_TAG"
echo ""

if [ "$LAST_TAG" = "none" ]; then
  echo "No previous tags found"
  exit 0
fi

echo "Commits since $LAST_TAG:"
git log ${LAST_TAG}..HEAD --oneline
echo ""

# Check for breaking changes
if git log ${LAST_TAG}..HEAD --oneline | grep -E '(BREAKING CHANGE|!)'; then
  echo "⚠️  Found breaking changes → Recommend MAJOR version bump"
# Check for features
elif git log ${LAST_TAG}..HEAD --oneline | grep 'feat:'; then
  echo "✓ Found features → Recommend MINOR version bump"
# Only fixes/docs/chores
else
  echo "✓ Only fixes/docs/chores → Recommend PATCH version bump"
fi
```

## Semantic Versioning Reference

Follow [Semantic Versioning](https://semver.org/):

| Type | When to Use | Example |
|------|-------------|---------|
| **MAJOR** (X.0.0) | Breaking changes | 1.0.0 → 2.0.0 |
| **MINOR** (0.X.0) | New features, backwards compatible | 0.1.0 → 0.2.0 |
| **PATCH** (0.0.X) | Bug fixes, backwards compatible | 0.1.0 → 0.1.1 |

## Pre-release Versions

For alpha, beta, or release candidates:

```bash
# Format: vX.Y.Z-beta.1
NEW_VERSION="0.2.0-beta.1"

# Update Cargo.toml
# version = "0.2.0-beta.1"

# Tag and push
git tag -a v0.2.0-beta.1 -m "Release v0.2.0-beta.1"
git push origin main && git push origin v0.2.0-beta.1
```

Pre-releases:
- Marked as prerelease in GitHub
- Don't update the `latest` Docker tag
- Useful for testing before final release

## Performance Optimization

This skill is optimized for performance:

1. **Parallel Push**: `git push origin main && git push origin vX.Y.Z` pushes commit and tag in one operation
2. **Single Build**: Only one `cargo build --release` to update Cargo.lock
3. **Automated**: No manual steps, reducing human error and time

## Troubleshooting

### Tag already exists

```bash
# Delete tag locally and remotely
git tag -d vX.Y.Z
git push origin :refs/tags/vX.Y.Z

# Delete GitHub release if created
gh release delete vX.Y.Z

# Recreate tag
```

### CI workflow failed

```bash
# View failed run
gh run list --workflow=release.yml --limit 5
gh run view <run-id> --log

# Common fixes:
# - Verify tag format is vX.Y.Z
# - Ensure Cargo.toml syntax is correct
# - Check that tests pass
```

### Wrong version number

```bash
# Delete bad tag and release
git tag -d vX.Y.Z
git push origin :refs/tags/vX.Y.Z
gh release delete vX.Y.Z

# Reset commit
git reset --hard HEAD~1
git push origin main --force

# Fix Cargo.toml and retry
```

## Post-Release Verification

After the workflow completes, verify:

```bash
# View release
gh release view vX.Y.Z

# Check Docker images
docker pull ghcr.io/francisfuzz/emoji_gen:vX.Y.Z
docker run --rm ghcr.io/francisfuzz/emoji_gen:vX.Y.Z --count 5

# List all release artifacts
gh release view vX.Y.Z --json assets --jq '.assets[].name'
```

**Expected artifacts:**
- `emoji_gen-linux-x86_64.tar.gz` (+ .sha256)
- `emoji_gen-linux-aarch64.tar.gz` (+ .sha256)
- `emoji_gen-macos-x86_64.tar.gz` (+ .sha256)
- `emoji_gen-macos-aarch64.tar.gz` (+ .sha256)
- `emoji_gen-windows-x86_64.exe.zip` (+ .sha256)

## Quick Reference

```bash
# Check current version
grep '^version = ' Cargo.toml

# Check last tag
git describe --tags --abbrev=0

# See commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Full release process (after determining version)
# 1. Edit Cargo.toml version
# 2. cargo build --release
# 3. git add Cargo.toml Cargo.lock
# 4. git commit -m "chore: bump version to X.Y.Z"
# 5. git tag -a vX.Y.Z -m "Release vX.Y.Z"
# 6. git push origin main && git push origin vX.Y.Z
# 7. gh run watch
```

## Integration with Other Skills

- **conventional-commits**: Used for the version bump commit message
- **release-process**: Provides comprehensive release documentation
- **git-workflow**: Ensures proper branch management before tagging

Use this skill when you're ready to tag and release, after all development work is complete and merged to main.
