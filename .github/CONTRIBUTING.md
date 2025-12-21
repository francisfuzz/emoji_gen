# Contributing to emoji_gen

Thank you for your interest in contributing to emoji_gen!

## Development Setup

See the [README](../README.md) for development setup instructions using either Docker or local Rust installation.

## Commit Message Convention

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Quick Format

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type | Description |
|------|-------------|
| `feat` | New feature for the user |
| `fix` | Bug fix |
| `docs` | Documentation only changes |
| `build` | Changes to build system, dependencies, Dockerfile, or CI |
| `test` | Adding or updating tests |
| `refactor` | Code changes that neither fix bugs nor add features |
| `perf` | Performance improvements |
| `chore` | Maintenance tasks, tooling changes |

### Examples

```bash
# Feature with scope
feat(cli): add --verbose flag for detailed output

# Bug fix
fix: prevent panic when emoji pool is empty

# Documentation
docs: update installation instructions

# Breaking change
feat!: change default output format to JSON

BREAKING CHANGE: stdout now outputs JSON instead of plain text
```

### Git Commit Template (Optional)

To automatically use the commit template:

```bash
# Configure for this repo only
git config commit.template .gitmessage

# Or configure globally
git config --global commit.template ~/.gitmessage
cp .gitmessage ~/.gitmessage
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Make your changes following the commit conventions
4. Ensure all tests pass: `./docker-dev.sh test` or `cargo test`
5. Ensure code is formatted: `./docker-dev.sh fmt-check` or `cargo fmt -- --check`
6. Ensure linting passes: `./docker-dev.sh clippy` or `cargo clippy -- -D warnings`
7. Push to your fork (`git push origin feat/amazing-feature`)
8. Open a Pull Request

## Code Quality Standards

All pull requests must:
- ✅ Pass all tests (`cargo test`)
- ✅ Pass clippy with no warnings (`cargo clippy -- -D warnings`)
- ✅ Be formatted with rustfmt (`cargo fmt`)
- ✅ Include tests for new functionality
- ✅ Update documentation if needed
- ✅ Follow Conventional Commits format

## Questions or Issues?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Documentation improvements
- Questions about the codebase

Thank you for contributing! 🎉
