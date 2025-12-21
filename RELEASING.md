# Release Process

This document describes how to create a new release of `emoji_gen`.

## Overview

Releases are fully automated via GitHub Actions. When you push a version tag, the workflow will:

1. Build binaries for multiple platforms (Linux, macOS, Windows)
2. Build and push multi-platform Docker images to GHCR
3. Create a GitHub Release with all artifacts
4. Generate checksums for verification

## Prerequisites

- Write access to the repository
- Clean working tree (all changes committed)
- All tests passing locally

## Release Steps

### 1. Update Version

Edit `Cargo.toml` and update the version:

```toml
[package]
version = "0.2.0"  # Update this
```

### 2. Update CHANGELOG (if you have one)

Document what changed in this release.

### 3. Commit Version Bump

```bash
git add Cargo.toml
git commit -m "chore: bump version to 0.2.0"
```

### 4. Create and Push Tag

```bash
# Create annotated tag
git tag -a v0.2.0 -m "Release v0.2.0"

# Push commit and tag
git push origin main
git push origin v0.2.0
```

### 5. Wait for CI

The GitHub Actions workflow will automatically:
- Build release binaries for all platforms
- Run tests and linting
- Build and push Docker images
- Create GitHub Release with artifacts

Monitor progress at: https://github.com/francisfuzz/emoji_gen/actions

### 6. Verify Release

Once the workflow completes:

1. Check the [Releases page](https://github.com/francisfuzz/emoji_gen/releases)
2. Verify all binary artifacts are present
3. Verify checksums are included
4. Test Docker image: `docker pull ghcr.io/francisfuzz/emoji_gen:v0.2.0`

### 7. (Optional) Publish to crates.io

If you want to publish to the Rust package registry:

```bash
cargo login <your-token>
cargo publish
```

## Supported Platforms

The release workflow builds for:

- **Linux**: x86_64, ARM64
- **macOS**: Intel (x86_64), Apple Silicon (aarch64)
- **Windows**: x86_64
- **Docker**: linux/amd64, linux/arm64

## Docker Image Tags

Each release creates multiple Docker tags:

- `ghcr.io/francisfuzz/emoji_gen:v0.2.0` - Specific version
- `ghcr.io/francisfuzz/emoji_gen:0.2` - Major.minor
- `ghcr.io/francisfuzz/emoji_gen:0` - Major version
- `ghcr.io/francisfuzz/emoji_gen:latest` - Latest release

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backwards compatible
- **PATCH** (0.0.1): Bug fixes, backwards compatible

## Troubleshooting

### Release workflow fails

1. Check the [Actions tab](https://github.com/francisfuzz/emoji_gen/actions)
2. Review the failed job logs
3. Fix the issue and create a new tag (e.g., v0.2.1)

### Docker image not appearing

1. Check that the workflow completed successfully
2. Verify package visibility is set to public in repository settings
3. May take a few minutes to appear in GHCR

### Binary doesn't work on target platform

1. Verify you downloaded the correct platform binary
2. Check the checksum: `sha256sum -c emoji_gen-*.sha256`
3. Ensure binary has execute permissions: `chmod +x emoji_gen`

## Rolling Back a Release

If you need to remove a bad release:

1. Delete the tag locally: `git tag -d v0.2.0`
2. Delete the tag remotely: `git push origin :refs/tags/v0.2.0`
3. Delete the GitHub Release from the web UI
4. Delete Docker images from GHCR (if needed)
5. Create a new release with a patch version

## First Release Checklist

Before creating v0.1.0:

- [ ] All tests pass
- [ ] Documentation is complete
- [ ] README has installation instructions
- [ ] LICENSE file exists
- [ ] Cargo.toml metadata is accurate
- [ ] CLAUDE.md is up to date
