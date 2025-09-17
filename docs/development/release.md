# Release Management Guide

This guide describes the process for creating new releases of the `cardano.nix` project.

**Note**: This process applies to releases v1.0.0 and later. Prior to v1.0.0, the project did not follow semantic versioning, maintain a changelog, or use conventional commits.

## Prerequisites

Before starting, ensure you have:

- Write access to the repository
- `git-cliff` installed (automatically available in the project's dev shell)
- Knowledge of [Conventional Commits](https://www.conventionalcommits.org/)

## System Overview

The project uses:

- **Semantic Versioning** (SemVer) for versioning
- **git-cliff** for automatic changelog generation
- **Conventional Commits** to automatically categorize changes
- Git tags in the format `v[0-9]*` (e.g., `v1.0.0`, `v1.1.0`)

## Release Process

### 1. Determine Next Version

Based on commits using SemVer:

- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (x.y.0): New backward-compatible features
- **PATCH** (x.y.z): Backward-compatible bug fixes

### 2. Generate and Review Changelog

Generate the changelog for the new version:

```bash
# Generate changelog for the next version (example: v1.1.0)
git-cliff --unreleased -t v1.1.0 --prepend CHANGELOG.md
```

**Important**: Review the generated changelog and:

- Remove any development-only commits (typo fixes, formatting, internal refactoring)
- Delete changes that are not significant enough for a changelog
- Merge related changes into a single entry when appropriate
- Fix any formatting issues
- Start the documentation site with `nix run .#docs.serve` to preview the rendering

### 3. Create Release Branch and Pull Request

```bash
# Create and switch to release branch
git checkout -b release/v1.1.0

# Commit the updated changelog
git add CHANGELOG.md
git commit -m "docs: update changelog for v1.1.0"

# Push release branch
git push origin release/v1.1.0
```

Create a pull request for the release branch and merge it using "Rebase and merge" to keep a clean history.

### 4. Create and Push Tag

After the PR is merged:

```bash
# Switch back to main and pull latest
git checkout main
git pull origin main

# Create and push the tag
git tag v1.1.0
git push origin v1.1.0
```
