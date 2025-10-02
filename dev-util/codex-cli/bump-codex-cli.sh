#!/bin/bash

# Automated Codex CLI Version Bump Script
# Usage: ./bump-codex-cli.sh [--force]
#
# This script checks for new codex-cli releases and automatically creates
# new ebuilds, generates manifests, and optionally tests the build.

set -euo pipefail

# Configuration
OVERLAY_DIR="/home/hendrik/src/overlay/dev-util/codex-cli"
GITHUB_REPO="openai/codex"
PACKAGE_NAME="codex-cli"
LOG_FILE="/tmp/bump-codex-cli.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Colored output functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to get current version from existing ebuilds
get_current_version() {
    local current_ebuild
    current_ebuild=$(find "$OVERLAY_DIR" -name "${PACKAGE_NAME}-*.ebuild" ! -name "*-9999.ebuild" | sort -V | tail -1)

    if [[ -n "$current_ebuild" ]]; then
        basename "$current_ebuild" | sed "s/${PACKAGE_NAME}-\(.*\)\.ebuild/\1/"
    else
        echo ""
    fi
}

# Function to get latest version from GitHub
get_latest_version() {
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

    # Try with curl first
    if command -v curl >/dev/null 2>&1; then
        curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"tag_name": *"rust-v?([^"]+)".*/\1/' 2>/dev/null || echo ""
    # Fallback to wget
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$api_url" | grep '"tag_name":' | sed -E 's/.*"tag_name": *"rust-v?([^"]+)".*/\1/' 2>/dev/null || echo ""
    else
        error "Neither curl nor wget available for GitHub API requests"
        exit 1
    fi
}

# Function to create new ebuild from existing one
create_new_ebuild() {
    local old_version="$1"
    local new_version="$2"
    local old_ebuild="${OVERLAY_DIR}/${PACKAGE_NAME}-${old_version}.ebuild"
    local new_ebuild="${OVERLAY_DIR}/${PACKAGE_NAME}-${new_version}.ebuild"

    if [[ ! -f "$old_ebuild" ]]; then
        error "Source ebuild not found: $old_ebuild"
        return 1
    fi

    info "Creating new ebuild: ${PACKAGE_NAME}-${new_version}.ebuild"
    cp "$old_ebuild" "$new_ebuild"

    # Update copyright year if needed
    local current_year
    current_year=$(date +%Y)
    sed -i "s/# Copyright [0-9]*-[0-9]*/# Copyright 1999-${current_year}/" "$new_ebuild"

    success "Created $new_ebuild"
}

# Function to generate manifest
generate_manifest() {
    info "Generating manifest..."

    cd "$OVERLAY_DIR"

    if command -v pkgdev >/dev/null 2>&1; then
        if pkgdev manifest; then
            success "Manifest generated successfully"
            return 0
        else
            error "pkgdev manifest failed"
            return 1
        fi
    elif command -v repoman >/dev/null 2>&1; then
        if repoman manifest; then
            success "Manifest generated successfully with repoman"
            return 0
        else
            error "repoman manifest failed"
            return 1
        fi
    else
        error "Neither pkgdev nor repoman available for manifest generation"
        return 1
    fi
}

# Function to test ebuild
test_ebuild() {
    local version="$1"
    local ebuild_file="${PACKAGE_NAME}-${version}.ebuild"

    info "Testing ebuild: $ebuild_file"

    cd "$OVERLAY_DIR"

    if ebuild "$ebuild_file" clean test 2>&1 | tee -a "$LOG_FILE"; then
        success "Ebuild test passed"
        return 0
    else
        error "Ebuild test failed"
        return 1
    fi
}

# Function to clean up old versions (optional)
cleanup_old_versions() {
    local current_version="$1"
    local keep_versions=3  # Keep last 3 versions

    info "Checking for old versions to clean up..."

    local old_ebuilds
    old_ebuilds=$(find "$OVERLAY_DIR" -name "${PACKAGE_NAME}-*.ebuild" ! -name "*-9999.ebuild" ! -name "${PACKAGE_NAME}-${current_version}.ebuild" | sort -V | head -n -$((keep_versions-1)))

    if [[ -n "$old_ebuilds" ]]; then
        warning "Found old ebuilds that could be removed:"
        echo "$old_ebuilds"
        warning "Consider removing them manually if no longer needed"
    fi
}

# Main function
main() {
    local force_update=false

    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --force)
                force_update=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--force] [--help]"
                echo "  --force    Force update even if versions match"
                echo "  --help     Show this help message"
                exit 0
                ;;
            *)
                error "Unknown argument: $arg"
                exit 1
                ;;
        esac
    done

    info "Starting codex-cli version bump check..."

    # Check if we're in the right directory
    if [[ ! -d "$OVERLAY_DIR" ]]; then
        error "Overlay directory not found: $OVERLAY_DIR"
        exit 1
    fi

    # Get current and latest versions
    local current_version
    current_version=$(get_current_version)

    if [[ -z "$current_version" ]]; then
        error "No current ebuild found in $OVERLAY_DIR"
        exit 1
    fi

    info "Current version: $current_version"

    local latest_version
    latest_version=$(get_latest_version)

    if [[ -z "$latest_version" ]]; then
        error "Failed to fetch latest version from GitHub"
        exit 1
    fi

    info "Latest version: $latest_version"

    # Compare versions
    if [[ "$current_version" == "$latest_version" ]] && [[ "$force_update" == false ]]; then
        success "Already up to date (version $current_version)"
        exit 0
    fi

    if [[ "$force_update" == true ]]; then
        warning "Force update requested"
    fi

    # Version comparison (basic)
    if [[ "$current_version" != "$latest_version" ]] || [[ "$force_update" == true ]]; then
        info "Update needed: $current_version -> $latest_version"

        # Create new ebuild
        if ! create_new_ebuild "$current_version" "$latest_version"; then
            error "Failed to create new ebuild"
            exit 1
        fi

        # Generate manifest
        if ! generate_manifest; then
            error "Failed to generate manifest"
            # Clean up failed ebuild
            rm -f "${OVERLAY_DIR}/${PACKAGE_NAME}-${latest_version}.ebuild"
            exit 1
        fi

        # Test ebuild (optional, can be slow)
        if [[ "${SKIP_TEST:-}" != "1" ]]; then
            info "Testing new ebuild (set SKIP_TEST=1 to skip)..."
            if ! test_ebuild "$latest_version"; then
                warning "Ebuild test failed, but files were created successfully"
                warning "Manual testing recommended: ebuild ${PACKAGE_NAME}-${latest_version}.ebuild clean test install"
            fi
        else
            info "Skipping ebuild test (SKIP_TEST=1)"
        fi

        # Cleanup old versions info
        cleanup_old_versions "$latest_version"

        success "Update completed successfully!"
        success "New ebuild: ${PACKAGE_NAME}-${latest_version}.ebuild"
        info "Consider testing with: ebuild ${PACKAGE_NAME}-${latest_version}.ebuild clean test install"

    else
        # This shouldn't happen with our logic above, but just in case
        info "No update needed"
    fi
}

# Run main function with all arguments
main "$@"