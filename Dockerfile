FROM rust:1.80-slim-bookworm AS builder

WORKDIR /usr/src/emoji_gen

# Copy only Cargo.toml for dependency caching
COPY Cargo.toml ./

# Create dummy files for dependency build
RUN mkdir -p src && \
    echo "pub fn dummy() {}" > src/lib.rs && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src target/release/.fingerprint/emoji_gen-* target/release/deps/emoji_gen-*

# Copy actual source
COPY src ./src

# Build with linting and testing
RUN rustup component add clippy && \
    cargo clippy -- -D warnings && \
    cargo test --release && \
    cargo build --release

# Runtime stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/emoji_gen/target/release/emoji_gen /usr/local/bin/
ENTRYPOINT ["emoji_gen"]
