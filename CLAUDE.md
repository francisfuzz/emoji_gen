# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`emoji_gen` is a Rust CLI application that outputs random emojis to stdout. It uses a lib/bin split architecture pattern where:
- `src/lib.rs` contains the core emoji generation logic and tests
- `src/main.rs` is a thin CLI wrapper using clap for argument parsing

### Project Skills

Workflow automation is available via Project Skills in `.claude/skills/`:
- `conventional-commits` - Commit message formatting
- `git-workflow` - Branch and PR workflow
- `git-tag-release` - Automated Git tagging and release triggering
- `release-process` - Version and release management

Skills activate automatically based on context.

## Architecture

**Lib/Bin Split Pattern**: All business logic lives in `lib.rs` (the library crate) for testability and reusability. The binary in `main.rs` only handles CLI argument parsing and output formatting.

**Core Logic**: The `generate_emojis(count: usize)` function in `src/lib.rs` returns a vector of randomly selected emojis from a constant `EMOJI_POOL`. It uses `rand::seq::SliceRandom` for random selection.

## Development Commands

### Local Development (requires Rust toolchain)
```bash
# Lint with clippy (enforced in CI/Docker)
cargo clippy -- -D warnings

# Run all tests
cargo test

# Run in debug mode
cargo run -- --count 5

# Build release binary
cargo build --release
```

### Docker Development
```bash
# Build image (includes clippy, tests, and release build)
docker build -t emoji-gen .

# Run with default (1 emoji)
docker run --rm emoji-gen

# Run with count argument
docker run --rm emoji-gen --count 10
docker run --rm emoji-gen -c 5
```

## Git Workflow

**IMPORTANT**: When starting any new work, ALWAYS use a branch-based workflow and create a draft pull request.

### Workflow for New Work

1. **Create a feature branch** from `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/descriptive-name
   # Or: fix/bug-name, docs/update-name, build/ci-change, etc.
   ```

2. **Make your changes** and commit following Conventional Commits format

3. **Push the branch** and create a draft PR:
   ```bash
   git push -u origin feat/descriptive-name
   gh pr create --draft --title "feat: add descriptive feature" --body "Description of changes"
   ```

4. **Continue working** - Push commits as you progress:
   ```bash
   git add .
   git commit -m "feat: implement core functionality"
   git push
   ```

5. **Mark PR as ready** when complete:
   ```bash
   gh pr ready
   ```

6. **Merge after CI passes** and review is complete

### Branch Naming Convention

Use Conventional Commits prefixes for branch names:

- `feat/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/documentation-update` - Documentation changes
- `build/ci-or-build-change` - Build system or CI changes
- `test/test-addition` - Test additions or updates
- `refactor/code-improvement` - Code refactoring
- `perf/performance-improvement` - Performance improvements
- `chore/maintenance-task` - Maintenance tasks

### When to Use This Workflow

**ALWAYS use feature branches and draft PRs for:**
- ✅ New features
- ✅ Bug fixes
- ✅ Refactoring
- ✅ Documentation updates
- ✅ CI/CD changes
- ✅ Any non-trivial changes

**Direct commits to main are ONLY acceptable for:**
- ❌ Emergency hotfixes (use with extreme caution)
- ❌ Version bumps for releases

### Pull Request Best Practices

**When creating a draft PR:**
1. Use a clear, descriptive title following Conventional Commits format
2. Include context in the PR description:
   - What changed and why
   - How to test the changes
   - Any breaking changes or special considerations
3. Link to related issues if applicable
4. Mark as draft until ready for review
5. Ensure CI passes before marking as ready

**Using GitHub CLI:**
```bash
# Create draft PR with auto-generated title from commits
gh pr create --draft --fill

# Create draft PR with custom title and body
gh pr create --draft --title "feat: add emoji filtering" --body "Adds ability to filter emojis by category"

# Mark PR as ready for review
gh pr ready

# View PR status
gh pr status

# View PR in browser
gh pr view --web
```

### Example Complete Workflow

```bash
# 1. Start new feature
git checkout main
git pull origin main
git checkout -b feat/add-emoji-categories

# 2. Make changes, commit following conventions
# ... edit files ...
git add src/lib.rs
git commit -m "feat: add emoji category support

Adds categorization system for emojis (animals, food, symbols).
Users can now filter by category using --category flag.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 3. Push and create draft PR
git push -u origin feat/add-emoji-categories
gh pr create --draft --title "feat: add emoji category filtering" --body "Implements emoji categorization and filtering by category"

# 4. Continue working, push more commits
# ... make more changes ...
git add .
git commit -m "feat: add category tests"
git push

# 5. When ready, mark PR as ready
gh pr ready

# 6. After CI passes and review is done, merge via GitHub UI or:
gh pr merge --squash
```

## Docker Build Architecture

The Dockerfile uses a **two-stage build with dependency caching**:

1. **Builder stage**: Creates a dummy build to cache dependencies (clap, rand), then removes only the `emoji_gen` artifacts before copying real source
2. **Runtime stage**: Copies only the compiled binary to a minimal Debian image

**Critical**: When modifying the Dockerfile's dependency caching layer, ensure you remove `target/release/.fingerprint/emoji_gen-*` and `target/release/deps/emoji_gen-*` to prevent build cache conflicts between dummy and real source.

## Testing

All tests are in `src/lib.rs` under the `#[cfg(test)]` module. Tests verify:
- Single emoji generation
- Multiple emoji generation
- Zero emoji edge case (returns empty vector)

The Dockerfile automatically runs tests during build, so a successful Docker build guarantees passing tests.

## Commit Conventions

This project follows the **Conventional Commits** specification. All commits MUST follow this format:

### Format

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: New feature for the user or library
- **fix**: Bug fix for the user
- **docs**: Documentation changes only
- **build**: Changes to build system or dependencies (Cargo.toml, Dockerfile, CI)
- **test**: Adding or updating tests
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Performance improvements
- **chore**: Maintenance tasks, tooling changes

### Scope (Optional)

Scope describes the section of the codebase, e.g., `feat(cli):`, `fix(parser):`, `build(docker):`

### Breaking Changes

Indicate breaking changes with `!` before the colon:
```
feat!: drop support for count=0
```

Or use `BREAKING CHANGE:` footer:
```
feat: change default emoji pool

BREAKING CHANGE: removed deprecated emojis from pool
```

### Examples

**Feature addition:**
```
feat: add emoji pool customization via config file

Allows users to specify custom emoji pools through a TOML config.
Defaults to built-in pool if no config is provided.
```

**Bug fix:**
```
fix: correct emoji count validation

Previously accepted negative counts, now returns error for count < 0.
```

**Build/CI change:**
```
build(docker): optimize dependency caching layer

Remove emoji_gen-specific artifacts to prevent cache conflicts between
dummy and real builds.
```

**Documentation:**
```
docs: add Docker development workflow to README

Includes docker-dev.sh helper script usage and examples.
```

**With scope and breaking change:**
```
feat(cli)!: replace --count with --num flag

BREAKING CHANGE: --count flag removed, use --num instead
```

### Commit Footer

Always include the Claude Code footer when creating commits:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Quick Reference

When creating commits:
1. Choose the appropriate type (feat, fix, docs, build, test, refactor, perf, chore)
2. Add optional scope in parentheses if it clarifies the change area
3. Use `!` after type/scope if introducing breaking changes
4. Write a clear, imperative description (e.g., "add" not "added")
5. Add body for context if the change needs explanation
6. Include footers for breaking changes or additional metadata
7. Always append the Claude Code footer

## Release Process

Releases are fully automated via GitHub Actions. See [RELEASING.md](RELEASING.md) for detailed instructions.

### Quick Release Steps

1. **Update version** in `Cargo.toml`
2. **Commit**: `git commit -m "chore: bump version to X.Y.Z"`
3. **Tag**: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
4. **Push**: `git push origin main && git push origin vX.Y.Z`

The CI workflow automatically:
- Builds binaries for Linux (x86_64, ARM64), macOS (Intel, Apple Silicon), Windows (x86_64)
- Publishes multi-platform Docker images to `ghcr.io/francisfuzz/emoji_gen`
- Creates GitHub Release with all artifacts and checksums
- Tags Docker images with version and `latest`

### Versioning

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.0.0): Breaking changes (use `!` in commit or `BREAKING CHANGE:` footer)
- **MINOR** (0.1.0): New features, backwards compatible
- **PATCH** (0.0.1): Bug fixes, backwards compatible

### Distribution Channels

Released artifacts are available via:
- **GitHub Releases**: Pre-compiled binaries for all platforms
- **GitHub Container Registry**: `ghcr.io/francisfuzz/emoji_gen:vX.Y.Z` and `:latest`
- **crates.io**: Available for `cargo install emoji_gen` (manual publish required)
