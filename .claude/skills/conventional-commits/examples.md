# Conventional Commits Examples

Real examples from the emoji_gen project.

## Feature Addition

```bash
git commit -m "$(cat <<'EOF'
feat: expand emoji pool to all Unicode emojis via emojis crate

Replaces hardcoded 20-emoji pool with dynamic pool of 1900+ emojis from the
emojis crate. Uses std::sync::LazyLock for O(1) selection with lazy initialization.

Changes:
- Add emojis crate dependency (v0.6)
- Replace const EMOJI_POOL with LazyLock-based dynamic pool
- Update tests to validate emojis from expanded pool
- Add test_emoji_pool_size to verify comprehensive coverage

Performance: Maintains O(1) random selection, one-time O(n) initialization

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Documentation Update

```bash
git commit -m "$(cat <<'EOF'
docs: update README and add MSRV requirement for LazyLock

Updates documentation to reflect expanded emoji pool and documents minimum
Rust version requirement for std::sync::LazyLock (stabilized in Rust 1.80).

Changes:
- Update README.md:7 to reflect 1900+ emoji pool (was 20)
- Update README.md:98 minimum Rust version to 1.80 (was 1.83)
- Add rust-version = "1.80" to Cargo.toml [package] section

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Build System Change

```bash
git commit -m "$(cat <<'EOF'
build: align Dockerfile and CI to MSRV 1.80

Ensures all build environments match the declared rust-version in Cargo.toml.
Adds MSRV CI check to verify builds and tests pass on minimum supported version.

Changes:
- Update Dockerfile to use rust:1.80-slim-bookworm (was 1.83)
- Update docker-dev.sh to use rust:1.80-slim-bookworm (was 1.83)
- Add MSRV check job to rust.yml workflow to test with Rust 1.80

This guarantees users on Rust 1.80+ (LazyLock minimum) can build the project.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Bug Fix

```bash
git commit -m "$(cat <<'EOF'
fix: correct emoji count validation

Previously accepted negative counts, now returns error for count < 0.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Breaking Change

```bash
git commit -m "$(cat <<'EOF'
feat!: drop support for count=0

BREAKING CHANGE: The count=0 parameter no longer returns an empty vector.
Use count=1 or higher. This change simplifies the API and removes an edge case.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Simple Chore

```bash
git commit -m "$(cat <<'EOF'
chore: bump version to 0.2.0

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Test Addition

```bash
git commit -m "$(cat <<'EOF'
test: add emoji pool size validation test

Verifies we have a comprehensive emoji pool (1800+ emojis from emojis crate).

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Refactoring

```bash
git commit -m "$(cat <<'EOF'
refactor: extract emoji selection logic to separate function

No functional changes, improves code organization and testability.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## CI/CD Change

```bash
git commit -m "$(cat <<'EOF'
build(ci): add MSRV check to GitHub Actions workflow

Ensures builds and tests pass on Rust 1.80 (declared MSRV).
Runs in parallel with existing stable Rust checks.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```
