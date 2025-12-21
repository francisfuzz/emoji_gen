# Pull Request Template

Use this template when creating pull requests for emoji_gen.

## Basic Template

```markdown
## Summary

[1-3 sentence overview of what changed and why]

## Changes

- [Key change 1]
- [Key change 2]
- [Key change 3]

## Test Plan

- [ ] Run `./docker-dev.sh test` - all tests pass
- [ ] Run `./docker-dev.sh clippy` - no warnings
- [ ] [Manual testing step if applicable]
- [ ] Verify CI passes

## Breaking Changes

[If applicable, describe any breaking changes and migration path]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Detailed Template (For Major Features)

```markdown
## Summary

[Detailed explanation of what changed and why. Include context and motivation.]

## Key Changes

**Core Logic:**
- [Description of core changes]

**Dependencies:**
- [New dependencies added, if any]

**Configuration:**
- [Config or build changes, if any]

**Testing:**
- [New tests added]

## Test Plan

**Automated Tests:**
- [ ] Run `./docker-dev.sh test` - all tests pass
- [ ] Run `./docker-dev.sh clippy` - no warnings
- [ ] Run `./docker-dev.sh fmt-check` - formatting correct

**Manual Testing:**
- [ ] [Specific manual test 1]
- [ ] [Specific manual test 2]
- [ ] Build Docker image: `docker build -t emoji-gen:test .`
- [ ] Run Docker container: `docker run --rm emoji-gen:test --count 5`

**CI Verification:**
- [ ] All GitHub Actions workflows pass
- [ ] MSRV check passes (Rust 1.80)
- [ ] Docker build succeeds

## Breaking Changes

[If applicable:]

**What breaks:**
- [Specific breaking change]

**Migration path:**
- [How users should update their code]

**Justification:**
- [Why this breaking change is necessary]

## Related Issues

Fixes #[issue number]
Closes #[issue number]

## Additional Context

[Any additional information reviewers should know]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Example PR (Real)

```markdown
## Summary

Expands the emoji pool from 20 hardcoded emojis to 1900+ Unicode emojis using the `emojis` crate, while maintaining O(1) random selection performance.

**Key Changes:**
- ✅ Added `emojis` crate dependency (v0.6)
- ✅ Replaced `const EMOJI_POOL` with `LazyLock<Vec<&'static str>>` for dynamic initialization
- ✅ Maintains O(1) random selection using `IndexedRandom::choose()`
- ✅ One-time O(n) initialization on first use (lazy evaluation)
- ✅ Updated tests to validate emojis from expanded pool
- ✅ Added `test_emoji_pool_size` to verify comprehensive coverage (1800+ emojis)

**Implementation Details:**

Uses Rust's `std::sync::LazyLock` (stable in Rust 1.80+) for thread-safe lazy initialization. The emoji pool is built once on first access and reused for all subsequent calls, maintaining optimal performance.

**Testing:**

All tests pass with the expanded pool:
- ✅ Clippy (no warnings)
- ✅ All unit tests passing
- ✅ Docker build verified

## Test Plan

- [x] Run `./docker-dev.sh clippy` - passes with no warnings
- [x] Run `./docker-dev.sh test` - all tests pass
- [x] Verify emoji pool size is 1800+ emojis
- [x] Verify generated emojis are valid Unicode emojis
- [ ] Manual testing: Run `docker build .` to verify Docker build
- [ ] Manual testing: Run app and verify diverse emoji output

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Creating PR via GitHub CLI

### Auto-fill from commits
```bash
gh pr create --draft --fill
```

### Custom title and body
```bash
gh pr create --draft \
  --title "feat: add emoji filtering by category" \
  --body "$(cat <<'EOF'
## Summary

Adds ability to filter emojis by category (animals, food, symbols, etc.)
using a new --category flag.

## Changes

- Add emoji categorization system
- Implement --category CLI flag
- Add category validation
- Update tests for category filtering

## Test Plan

- [ ] Run `./docker-dev.sh test`
- [ ] Run `./docker-dev.sh clippy`
- [ ] Test: `cargo run -- --category animals --count 5`
- [ ] Verify only animal emojis are returned

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Body from file
```bash
gh pr create --draft --title "feat: something" --body-file pr-body.md
```
