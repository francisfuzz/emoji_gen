# Release Checklist

Use this checklist when preparing a release for emoji_gen.

## Pre-Release

### 1. Preparation
- [ ] On `main` branch: `git branch --show-current`
- [ ] Up to date with remote: `git pull origin main`
- [ ] No uncommitted changes: `git status`

### 2. Version Decision
- [ ] Review commits since last release: `git log $(git describe --tags --abbrev=0)..HEAD --oneline`
- [ ] Determine version bump type:
  - [ ] MAJOR: Breaking changes (has `!` or `BREAKING CHANGE:`)
  - [ ] MINOR: New features (has `feat:`)
  - [ ] PATCH: Bug fixes only (has `fix:`, `docs:`, etc.)
- [ ] Chosen version: `_____`

### 3. Code Quality
- [ ] All tests pass: `./docker-dev.sh test`
- [ ] Clippy passes with no warnings: `./docker-dev.sh clippy`
- [ ] Code formatting is correct: `./docker-dev.sh fmt-check`

### 4. Version Update
- [ ] Update `version` in `Cargo.toml` to new version
- [ ] Run `cargo build` to update `Cargo.lock`
- [ ] Commit version bump:
  ```bash
  git add Cargo.toml Cargo.lock
  git commit -m "chore: bump version to X.Y.Z"
  ```

## Release

### 5. Tagging
- [ ] Create annotated tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Verify tag: `git tag -l vX.Y.Z`
- [ ] Tag format is correct: `vX.Y.Z` (with v prefix)

### 6. Push
- [ ] Push commit: `git push origin main`
- [ ] Push tag: `git push origin vX.Y.Z`
- [ ] Verify tag on GitHub: `gh release list` or check https://github.com/francisfuzz/emoji_gen/tags

### 7. Monitor CI
- [ ] Watch workflow: `gh run watch`
- [ ] Or view in browser: `gh run view --web`
- [ ] Wait for all jobs to complete successfully

## Post-Release

### 8. Verify Artifacts

**GitHub Release:**
- [ ] Release created: `gh release view vX.Y.Z`
- [ ] Binary: `emoji_gen-linux-x86_64.tar.gz` present
- [ ] Binary: `emoji_gen-linux-aarch64.tar.gz` present
- [ ] Binary: `emoji_gen-macos-x86_64.tar.gz` present
- [ ] Binary: `emoji_gen-macos-aarch64.tar.gz` present
- [ ] Binary: `emoji_gen-windows-x86_64.exe.zip` present
- [ ] SHA256 checksums for all binaries present
- [ ] Release notes auto-generated

**Docker Registry:**
- [ ] Pull version tag: `docker pull ghcr.io/francisfuzz/emoji_gen:vX.Y.Z`
- [ ] Pull latest tag: `docker pull ghcr.io/francisfuzz/emoji_gen:latest`
- [ ] Test Docker image: `docker run --rm ghcr.io/francisfuzz/emoji_gen:vX.Y.Z --count 5`
- [ ] Multi-platform support verified (linux/amd64, linux/arm64)

### 9. Smoke Testing
- [ ] Download and test at least one binary
- [ ] Run Docker container and verify output
- [ ] Check version output if applicable

### 10. Optional: Publish to crates.io
- [ ] Checkout tag: `git checkout vX.Y.Z`
- [ ] Publish: `cargo publish`
- [ ] Verify on crates.io: https://crates.io/crates/emoji_gen
- [ ] Return to main: `git checkout main`

### 11. Documentation
- [ ] Update README if version-specific instructions changed
- [ ] Announce release if appropriate

## Troubleshooting

### CI Failed
- [ ] Check workflow logs: `gh run view --log`
- [ ] Fix issues
- [ ] Delete tag if needed: `git tag -d vX.Y.Z && git push origin :refs/tags/vX.Y.Z`
- [ ] Delete release: `gh release delete vX.Y.Z`
- [ ] Retry after fixes

### Wrong Version
- [ ] Delete tag locally: `git tag -d vX.Y.Z`
- [ ] Delete tag remotely: `git push origin :refs/tags/vX.Y.Z`
- [ ] Delete release: `gh release delete vX.Y.Z`
- [ ] Fix `Cargo.toml`
- [ ] Create new commit and tag

## Quick Commands Reference

```bash
# Check current status
grep '^version = ' Cargo.toml
git describe --tags --abbrev=0

# See what changed
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Update version (edit Cargo.toml)
# Then commit
git add Cargo.toml Cargo.lock
git commit -m "chore: bump version to X.Y.Z"

# Create and push release
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin main
git push origin vX.Y.Z

# Monitor
gh run watch

# Verify
gh release view vX.Y.Z
docker pull ghcr.io/francisfuzz/emoji_gen:vX.Y.Z
```

## Notes

- Pre-releases (alpha, beta, rc) should use format: `vX.Y.Z-beta.1`
- Pre-releases don't update the `latest` Docker tag
- Always use annotated tags (`-a`) not lightweight tags
- The `v` prefix in tags is required
- CI publishes to GHCR automatically; crates.io is manual
