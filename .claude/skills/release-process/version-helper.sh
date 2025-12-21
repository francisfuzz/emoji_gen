#!/bin/bash
# Helper script for emoji_gen releases
# Usage: ./version-helper.sh [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current version from Cargo.toml
get_current_version() {
    grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'
}

# Get latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo "none"
}

# Show commits since last tag
show_commits_since_tag() {
    local last_tag=$(get_latest_tag)

    if [ "$last_tag" = "none" ]; then
        echo -e "${YELLOW}No tags found. Showing all commits:${NC}"
        git log --oneline
    else
        echo -e "${GREEN}Commits since $last_tag:${NC}"
        git log ${last_tag}..HEAD --oneline

        echo ""
        echo -e "${YELLOW}Analyzing commits for version bump...${NC}"

        # Check for breaking changes
        if git log ${last_tag}..HEAD --oneline | grep -E '(BREAKING CHANGE|!)'; then
            echo -e "${RED}⚠️  Found breaking changes → Recommend MAJOR version bump${NC}"
        # Check for features
        elif git log ${last_tag}..HEAD --oneline | grep 'feat:'; then
            echo -e "${GREEN}✓ Found features → Recommend MINOR version bump${NC}"
        # Only fixes/docs/chores
        else
            echo -e "${GREEN}✓ Only fixes/docs/chores → Recommend PATCH version bump${NC}"
        fi
    fi
}

# Show current status
show_status() {
    local current_version=$(get_current_version)
    local latest_tag=$(get_latest_tag)

    echo -e "${GREEN}Current version in Cargo.toml:${NC} $current_version"
    echo -e "${GREEN}Latest git tag:${NC} $latest_tag"
    echo ""

    if [ "$latest_tag" != "none" ] && [ "v$current_version" != "$latest_tag" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch: Cargo.toml ($current_version) != git tag ($latest_tag)${NC}"
    fi
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

# Pre-release checklist
pre_release_checklist() {
    echo -e "${GREEN}=== Pre-Release Checklist ===${NC}"
    echo ""

    # Check we're on main branch
    local branch=$(git branch --show-current)
    if [ "$branch" != "main" ]; then
        echo -e "${RED}✗ Not on main branch (currently on: $branch)${NC}"
    else
        echo -e "${GREEN}✓ On main branch${NC}"
    fi

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}✗ Uncommitted changes present${NC}"
    else
        echo -e "${GREEN}✓ No uncommitted changes${NC}"
    fi

    # Check if we're up to date with remote
    git fetch origin main --quiet
    local local_commit=$(git rev-parse main)
    local remote_commit=$(git rev-parse origin/main)
    if [ "$local_commit" != "$remote_commit" ]; then
        echo -e "${YELLOW}⚠️  Local main is not up to date with origin/main${NC}"
    else
        echo -e "${GREEN}✓ Up to date with origin/main${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Manual checks:${NC}"
    echo "  □ Tests pass: ./docker-dev.sh test"
    echo "  □ Clippy passes: ./docker-dev.sh clippy"
    echo "  □ Version number updated in Cargo.toml"
}

# Show help
show_help() {
    cat << EOF
emoji_gen Release Helper

Usage: $0 [command]

Commands:
    status          Show current version and tag status
    commits         Show commits since last tag and suggest version bump
    checklist       Run pre-release checklist
    help            Show this help message

Examples:
    # Check current status
    $0 status

    # See what changed since last release
    $0 commits

    # Run pre-release checklist
    $0 checklist
EOF
}

# Main command dispatcher
case "${1:-help}" in
    status)
        show_status
        ;;
    commits)
        show_commits_since_tag
        ;;
    checklist)
        pre_release_checklist
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
