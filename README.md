# emoji_gen

A simple Rust-based CLI application that generates random emojis to stdout.

## Features

- Generate random emojis from a curated pool of 20 emojis
- Support for generating single or multiple emojis
- Clean command-line interface with `--count` flag
- Available as both a local Rust binary and a Docker container

## Quick Start with Docker

The easiest way to use `emoji_gen` is with Docker (no Rust installation required):

### Clone the Repository

```bash
git clone https://github.com/francisfuzz/emoji_gen.git
cd emoji_gen
```

### Build and Run with Docker

```bash
# Build the Docker image
docker build -t emoji-gen .

# Generate a single emoji (default)
docker run --rm emoji-gen

# Generate multiple emojis
docker run --rm emoji-gen --count 5
docker run --rm emoji-gen -c 10
```

## Running Locally with Rust

If you have Rust installed, you can build and run the project natively:

### Prerequisites

- Rust 1.83 or later (install from [rustup.rs](https://rustup.rs))

### Clone and Navigate

```bash
git clone https://github.com/francisfuzz/emoji_gen.git
cd emoji_gen
```

### Build and Run

```bash
# Run in debug mode
cargo run

# Run with arguments
cargo run -- --count 5

# Build optimized release binary
cargo build --release

# Run the release binary directly
./target/release/emoji_gen --count 3
```

## Usage Examples

```bash
# Single emoji (default)
$ emoji_gen
🎉

# Five random emojis
$ emoji_gen --count 5
😀 🦀 🍕 💻 🎉

# Using short flag
$ emoji_gen -c 3
🔥 🤖 ⚡

# View help
$ emoji_gen --help
```

## Development

### With Docker (No Rust Installation Required)

Use the included helper script for development tasks:

```bash
# Make script executable (first time only)
chmod +x docker-dev.sh

# Auto-fix code formatting
./docker-dev.sh fmt

# Check formatting (what CI runs)
./docker-dev.sh fmt-check

# Run linter
./docker-dev.sh clippy

# Run tests
./docker-dev.sh test

# Build the project
./docker-dev.sh build

# Run the project
./docker-dev.sh run --count 10
```

### With Local Rust Installation

If you have Rust installed locally:

```bash
# Format code
cargo fmt

# Check formatting
cargo fmt -- --check

# Run linter
cargo clippy -- -D warnings

# Run tests
cargo test

# Run with arguments
cargo run -- --count 10
```

## License

See [LICENSE](LICENSE) file for details.
