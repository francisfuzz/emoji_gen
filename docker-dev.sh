#!/bin/bash
# Helper script for running Rust development commands via Docker
# Usage: ./docker-dev.sh [command]

set -e

RUST_IMAGE="rust:1.80-slim-bookworm"
WORKDIR="/usr/src/emoji_gen"

case "$1" in
  fmt)
    echo "Running cargo fmt..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      sh -c "rustup component add rustfmt && cargo fmt"
    ;;

  fmt-check)
    echo "Checking formatting..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      sh -c "rustup component add rustfmt && cargo fmt -- --check"
    ;;

  clippy)
    echo "Running clippy..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      sh -c "rustup component add clippy && cargo clippy -- -D warnings"
    ;;

  test)
    echo "Running tests..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      cargo test --verbose
    ;;

  build)
    echo "Building project..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      cargo build --verbose
    ;;

  run)
    shift
    echo "Running project..."
    docker run --rm -v "$(pwd):$WORKDIR" -w "$WORKDIR" "$RUST_IMAGE" \
      cargo run -- "$@"
    ;;

  *)
    echo "Usage: ./docker-dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  fmt         - Auto-fix code formatting"
    echo "  fmt-check   - Check code formatting (CI mode)"
    echo "  clippy      - Run Rust linter"
    echo "  test        - Run tests"
    echo "  build       - Build the project"
    echo "  run [args]  - Run the project with optional arguments"
    echo ""
    echo "Examples:"
    echo "  ./docker-dev.sh fmt"
    echo "  ./docker-dev.sh fmt-check"
    echo "  ./docker-dev.sh test"
    echo "  ./docker-dev.sh run --count 5"
    exit 1
    ;;
esac
