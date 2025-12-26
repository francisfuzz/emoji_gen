#!/bin/bash
# Automated release tagging script for emoji_gen
# Usage: ./tag-release.sh [new-version]
# Example: ./tag-release.sh 0.2.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version from Cargo.toml
get_current_version() {
    grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'
}

# Get latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo "none"
}

# Validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        echo -e "${RED}Error: Invalid version format: $version${NC}"
        echo "Expected format: X.Y.Z or X.Y.Z-prerelease"
        exit 1
    fi
}

# Analyze commits and suggest version bump
analyze_commits() {
    local last_tag=$(get_latest_tag)

    echo -e "${BLUE}=== Commit Analysis ===${NC}"
    echo ""

    if [ "$last_tag" = "none" ]; then
        echo -e "${YELLOW}No previous tags found${NC}"
        echo "Showing all commits:"
        git log --oneline --max-count=10
        return
    fi

    echo -e "Commits since ${GREEN}$last_tag${NC}:"
    git log ${last_tag}..HEAD --oneline
    echo ""

    # Analyze for version bump suggestion
    if git log ${last_tag}..HEAD --oneline | grep -qE '(BREAKING CHANGE|!)'; then
        echo -e "${RED}⚠️  Found breaking changes → Recommend MAJOR version bump${NC}"
    elif git log ${last_tag}..HEAD --oneline | grep -q 'feat:'; then
        echo -e "${GREEN}✓ Found features → Recommend MINOR version bump${NC}"
    else
        echo -e "${GREEN}✓ Only fixes/docs/chores → Recommend PATCH version bump${NC}"
    fi
    echo ""
}

# Pre-release checks
pre_release_checks() {
    echo -e "${BLUE}=== Pre-Release Checks ===${NC}"
    echo ""

    # Check we're on main branch
    local branch=$(git branch --show-current)
    if [ "$branch" != "main" ]; then
        echo -e "${RED}✗ Not on main branch (currently on: $branch)${NC}"
        echo "Please switch to main before tagging a release"
        exit 1
    fi
    echo -e "${GREEN}✓ On main branch${NC}"

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}✗ Uncommitted changes present${NC}"
        echo "Please commit or stash changes before releasing"
        exit 1
    fi
    echo -e "${GREEN}✓ No uncommitted changes${NC}"

    # Check if we're up to date with remote
    git fetch origin main --quiet
    local local_commit=$(git rev-parse main)
    local remote_commit=$(git rev-parse origin/main)
    if [ "$local_commit" != "$remote_commit" ]; then
        echo -e "${RED}✗ Local main is not up to date with origin/main${NC}"
        echo "Please pull latest changes: git pull origin main"
        exit 1
    fi
    echo -e "${GREEN}✓ Up to date with origin/main${NC}"

    echo ""
}

# Update Cargo.toml version
update_cargo_version() {
    local new_version=$1
    local current_version=$(get_current_version)

    echo -e "${BLUE}=== Updating Cargo.toml ===${NC}"
    echo "Changing version from $current_version to $new_version"

    # Use sed to update version in Cargo.toml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
    else
        # Linux
        sed -i "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
    fi

    echo -e "${GREEN}✓ Cargo.toml updated${NC}"
    echo ""
}

# Update Cargo.lock
update_cargo_lock() {
    echo -e "${BLUE}=== Updating Cargo.lock ===${NC}"
    echo "Running cargo build to update Cargo.lock..."

    cargo build --release --quiet

    echo -e "${GREEN}✓ Cargo.lock updated${NC}"
    echo ""
}

# Commit version bump
commit_version_bump() {
    local new_version=$1

    echo -e "${BLUE}=== Committing Version Bump ===${NC}"

    git add Cargo.toml Cargo.lock

    git commit -m "$(cat <<EOF
chore: bump version to $new_version

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

    echo -e "${GREEN}✓ Version bump committed${NC}"
    echo ""
}

# Create annotated tag
create_tag() {
    local new_version=$1
    local tag_name="v$new_version"

    echo -e "${BLUE}=== Creating Annotated Tag ===${NC}"

    git tag -a "$tag_name" -m "Release $tag_name"

    echo -e "${GREEN}✓ Tag $tag_name created${NC}"
    echo ""
}

# Push commit and tag
push_release() {
    local new_version=$1
    local tag_name="v$new_version"

    echo -e "${BLUE}=== Pushing to Remote ===${NC}"
    echo "Pushing commit and tag to origin..."

    # Push commit and tag in parallel for performance
    git push origin main && git push origin "$tag_name"

    echo -e "${GREEN}✓ Commit and tag pushed${NC}"
    echo -e "${GREEN}✓ Release workflow triggered!${NC}"
    echo ""
}

# Monitor release
monitor_release() {
    echo -e "${BLUE}=== Monitoring Release ===${NC}"
    echo "Watching GitHub Actions workflow..."
    echo ""

    # Check if gh is available
    if command -v gh &> /dev/null; then
        gh run watch
    else
        echo -e "${YELLOW}GitHub CLI not found. Monitor manually at:${NC}"
        echo "https://github.com/francisfuzz/emoji_gen/actions"
    fi
}

# Show usage
show_usage() {
    cat << EOF
${BLUE}emoji_gen Release Tagging Script${NC}

${GREEN}Usage:${NC}
    $0 [new-version]

${GREEN}Examples:${NC}
    $0 0.2.0          Tag version 0.2.0
    $0 0.2.0-beta.1   Tag pre-release version 0.2.0-beta.1

${GREEN}What this script does:${NC}
    1. Analyzes commits since last tag
    2. Performs pre-release checks
    3. Updates Cargo.toml version
    4. Updates Cargo.lock (via cargo build)
    5. Commits version bump
    6. Creates annotated tag
    7. Pushes commit and tag to trigger CI
    8. Monitors release workflow

${GREEN}Pre-requisites:${NC}
    - On main branch
    - No uncommitted changes
    - Up to date with origin/main
    - Tests pass: ./docker-dev.sh test
    - Clippy passes: ./docker-dev.sh clippy

${GREEN}Version Format:${NC}
    X.Y.Z or X.Y.Z-prerelease
    - MAJOR: Breaking changes
    - MINOR: New features
    - PATCH: Bug fixes
EOF
}

# Main script
main() {
    # Show usage if no arguments
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi

    local new_version=$1
    local current_version=$(get_current_version)

    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   emoji_gen Release Tagging Script   ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    # Validate version format
    validate_version "$new_version"

    # Show current state
    echo -e "${GREEN}Current version:${NC} $current_version"
    echo -e "${GREEN}New version:${NC} $new_version"
    echo -e "${GREEN}Tag to create:${NC} v$new_version"
    echo ""

    # Analyze commits
    analyze_commits

    # Pre-release checks
    pre_release_checks

    # Confirm with user
    echo -e "${YELLOW}Ready to tag release v$new_version${NC}"
    read -p "Continue? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 0
    fi
    echo ""

    # Execute release steps
    update_cargo_version "$new_version"
    update_cargo_lock
    commit_version_bump "$new_version"
    create_tag "$new_version"
    push_release "$new_version"

    # Success message
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Release Tagged Successfully!   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Release:${NC} v$new_version"
    echo -e "${GREEN}Workflow:${NC} https://github.com/francisfuzz/emoji_gen/actions"
    echo ""

    # Optionally monitor release
    read -p "Monitor release workflow? (Y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        monitor_release
    fi

    echo ""
    echo -e "${GREEN}Done! 🚀${NC}"
}

# Run main function
main "$@"
