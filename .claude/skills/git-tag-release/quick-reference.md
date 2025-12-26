# Git Tag Release - Quick Reference

## When to Use This Skill

Use this skill when you're ready to:
- Tag a new release version
- Trigger the automated CI/CD release workflow
- Push a version to GitHub Releases and GHCR

**Prerequisites:**
- All changes committed and merged to main
- Tests pass: `./docker-dev.sh test`
- Clippy passes: `./docker-dev.sh clippy`
- You've determined the new version number

## Quick Start

### Option 1: Using the Helper Script (Recommended)

```bash
# Automated release tagging
./.claude/skills/git-tag-release/tag-release.sh 0.2.0
```

The script will:
1. Analyze commits and suggest version bump
2. Check pre-release requirements
3. Update Cargo.toml and Cargo.lock
4. Commit version bump
5. Create annotated tag
6. Push commit and tag (triggers CI)
7. Monitor release workflow

### Option 2: Manual Steps

```bash
# 1. Determine version (see commits)
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 2. Update Cargo.toml
# Edit version = "X.Y.Z"

# 3. Update Cargo.lock
cargo build --release

# 4. Commit
git add Cargo.toml Cargo.lock
git commit -m "chore: bump version to X.Y.Z"

# 5. Tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# 6. Push (performant - single operation)
git push origin main && git push origin vX.Y.Z

# 7. Monitor
gh run watch
```

## Version Bump Decision Tree

```
Has BREAKING CHANGE or ! ?
├─ Yes → MAJOR (1.0.0 → 2.0.0)
└─ No
   └─ Has feat: commits?
      ├─ Yes → MINOR (0.1.0 → 0.2.0)
      └─ No → PATCH (0.1.0 → 0.1.1)
```

## Common Commands

```bash
# Check current version
grep '^version = ' Cargo.toml

# Check last tag
git describe --tags --abbrev=0

# See what changed
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Run automated tagging
./.claude/skills/git-tag-release/tag-release.sh 0.2.0

# Monitor release
gh run watch

# View release
gh release view vX.Y.Z
```

## Performance Features

This skill is optimized for speed:

1. **Parallel Push**: Commit and tag pushed together
2. **Single Build**: One `cargo build` to update Cargo.lock
3. **Automated**: No manual file editing required with helper script
4. **Immediate CI Trigger**: Tag push immediately starts workflow

## Pre-release Versions

For beta/alpha releases:

```bash
# Format: vX.Y.Z-beta.1
./.claude/skills/git-tag-release/tag-release.sh 0.2.0-beta.1
```

Pre-releases don't update the `latest` Docker tag.

## Troubleshooting

### Script fails with "not on main branch"
```bash
git checkout main
git pull origin main
```

### Script fails with "uncommitted changes"
```bash
git status
git add .
git commit -m "..."
```

### Tag already exists
```bash
# Delete tag locally and remotely
git tag -d vX.Y.Z
git push origin :refs/tags/vX.Y.Z
gh release delete vX.Y.Z

# Retry
```

### CI workflow failed
```bash
gh run list --workflow=release.yml --limit 5
gh run view <run-id> --log
```

## Post-Release Verification

```bash
# View release
gh release view vX.Y.Z

# Test Docker image
docker pull ghcr.io/francisfuzz/emoji_gen:vX.Y.Z
docker run --rm ghcr.io/francisfuzz/emoji_gen:vX.Y.Z --count 5

# List artifacts
gh release view vX.Y.Z --json assets --jq '.assets[].name'
```

## Integration with Project Workflow

1. **Development**: Use `git-workflow` skill for feature branches
2. **Commits**: Use `conventional-commits` skill for commit messages
3. **Release**: Use `git-tag-release` skill to tag and deploy
4. **Reference**: Use `release-process` skill for comprehensive docs

## Examples

### Patch Release (Bug Fix)
```bash
# Only bug fixes since last release
./.claude/skills/git-tag-release/tag-release.sh 0.1.3
```

### Minor Release (New Feature)
```bash
# New feature added
./.claude/skills/git-tag-release/tag-release.sh 0.2.0
```

### Major Release (Breaking Change)
```bash
# Breaking changes introduced
./.claude/skills/git-tag-release/tag-release.sh 1.0.0
```

### Pre-release
```bash
# Beta version for testing
./.claude/skills/git-tag-release/tag-release.sh 0.2.0-beta.1
```
