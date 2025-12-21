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
