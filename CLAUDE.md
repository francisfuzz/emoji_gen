# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`emoji_gen` is a Rust CLI application that outputs random emojis to stdout. It uses a lib/bin split architecture pattern where:
- `src/lib.rs` contains the core emoji generation logic and tests
- `src/main.rs` is a thin CLI wrapper using clap for argument parsing

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
