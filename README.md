# emoji_gen

A simple Rust-based CLI application that generates random emojis to stdout.

## Motivation

Inspired by Oxide Computer Company's [`Why does Oxide use Rust?` blog post](https://oxide.computer/faq-friday/why-does-oxide-use-rust): I created this project to understand how I could build a Rust-based CLI with Claude with my free hours on the weekend. I learned about Cargo as a build system, setting up core Actions workflows for the software development lifecycle, the [`emojis` package](https://github.com/rossmacarthur/emojis), and how to optimize my token usage with Claude by defining instructions once in CLAUDE.md (with a refactors towards `.claude/skills` along the way). It's been great fun! 🦀

## Features

- Generate random emojis from a comprehensive pool of 1900+ Unicode emojis
- Support for generating single or multiple emojis
- Clean command-line interface with `--count` flag
- Available as both a local Rust binary and a Docker container

## Installation

### Pre-compiled Binaries (Recommended)

Download the latest release for your platform from the [Releases page](https://github.com/francisfuzz/emoji_gen/releases):

**Linux (x86_64):**
```bash
curl -LO https://github.com/francisfuzz/emoji_gen/releases/latest/download/emoji_gen-linux-x86_64.tar.gz
tar xzf emoji_gen-linux-x86_64.tar.gz
sudo mv emoji_gen /usr/local/bin/
```

**macOS (Intel):**
```bash
curl -LO https://github.com/francisfuzz/emoji_gen/releases/latest/download/emoji_gen-macos-x86_64.tar.gz
tar xzf emoji_gen-macos-x86_64.tar.gz
sudo mv emoji_gen /usr/local/bin/
```

**macOS (Apple Silicon):**
```bash
curl -LO https://github.com/francisfuzz/emoji_gen/releases/latest/download/emoji_gen-macos-aarch64.tar.gz
tar xzf emoji_gen-macos-aarch64.tar.gz
sudo mv emoji_gen /usr/local/bin/
```

**Windows:**

Download `emoji_gen-windows-x86_64.zip` from the [Releases page](https://github.com/francisfuzz/emoji_gen/releases), extract it, and add the directory to your PATH.

### Docker (GitHub Container Registry)

Pull and run the official Docker image:

```bash
# Pull the latest image
docker pull ghcr.io/francisfuzz/emoji_gen:latest

# Run it
docker run --rm ghcr.io/francisfuzz/emoji_gen:latest --count 5

# Or use a specific version
docker pull ghcr.io/francisfuzz/emoji_gen:v0.1.1
docker run --rm ghcr.io/francisfuzz/emoji_gen:v0.1.1
```

### Cargo (Rust Package Manager)

If you have Rust installed:

```bash
cargo install emoji_gen
```

## Quick Start (Building from Source)

If you want to build from source:

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

- Rust 1.80 or later (install from [rustup.rs](https://rustup.rs))

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

## Contributing

Contributions are welcome! This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

Before submitting a PR, please ensure:
- Tests pass: `./docker-dev.sh test`
- Code is formatted: `./docker-dev.sh fmt-check`
- Linting passes: `./docker-dev.sh clippy`

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for detailed guidelines.

## License

See [LICENSE](LICENSE) file for details.
