# GitHub Actions Improvements Plan

This document outlines the improvements we can make to the GitHub Actions workflows in the Sploosh AI Sports Analytics project, based on the reference project at `/Users/rob/repos/sploosh.ai-projects/demo-hello-tdr`.

## Current Workflow Analysis

The sports analytics project currently has two main workflows:

1. `semantic-pr-check.yml` - Validates PR titles follow semantic versioning format
2. `main-merge.yml` - Handles version bumping after merges to main

## Recommended Improvements

### 1. Update `main-merge.yml`

The reference project has several improvements in its `main-merge.yml` that we should incorporate:

- **Version Tracking**: Add code to extract and display the new version number
- **Commit Message Enhancement**: Include the new version number in the commit message
- **Multi-package Support**: If we add more package.json files in subdirectories, update the workflow to bump versions in all of them

```yaml
# Update version in package.json
npm version ${{ steps.bump-type.outputs.bump_type }} --no-git-tag-version

# Get the new version number
NEW_VERSION=$(node -p "require('./package.json').version")
echo "New version: $NEW_VERSION"

# Stage and commit changes
git add package.json
git commit -m "chore: bump version to $NEW_VERSION [skip ci]"
```

### 2. Add `cleanup_ghcr.yml` Workflow

If we start using GitHub Container Registry (GHCR) for Docker images, we should add the `cleanup_ghcr.yml` workflow to manage old container images:

- Automatically cleans up old container images
- Configurable retention policy (keep X latest versions, keep versions newer than Y days)
- Supports dry-run mode for testing
- Provides detailed reporting in GitHub Actions summary

### 3. Add `deploy.yml` Workflow (When Needed)

If the sports analytics project evolves to include web applications or services, we can adapt the `deploy.yml` workflow:

- Build and push Docker images to GHCR
- Support for multi-architecture builds (amd64, arm64)
- Proper caching for faster builds
- Version tagging based on package.json

### 4. Windsurf Rules Integration

Consider adding Windsurf-specific rules for code quality and testing:

- Add linting checks for shell scripts
- Add validation for data file formats
- Add tests for data download scripts

## Implementation Plan

1. Update `main-merge.yml` with version tracking improvements
2. Create a basic test workflow for shell scripts
3. Add GHCR cleanup workflow if/when we start using Docker containers
4. Document the workflows in a central location for easier maintenance

## Next Steps

1. Implement the `main-merge.yml` improvements
2. Add shell script testing
3. Review and update documentation
