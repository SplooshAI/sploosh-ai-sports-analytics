# Node.js v24 LTS Upgrade Guide

## Overview

This document outlines the upgrade from Node.js v22 to Node.js v24 LTS for the sploosh-ai-sports-analytics project.

## Migration Details

### Node.js v24 LTS Information

- **Release Date**: November 4th, 2025
- **LTS Support Until**: April 2028
- **Current Version**: v24.11.0

### Migration Guide Reference

Official migration guide: <https://nodejs.org/en/blog/migrations/v22-to-v24>

### Key Breaking Changes

1. **OpenSSL 3.5**
   - RSA, DSA, and DH keys shorter than 2048 bits are prohibited
   - ECC keys shorter than 224 bits are prohibited
   - RC4 cipher suites are prohibited

2. **Platform Support**
   - Dropped 32-bit Windows (x86)
   - Dropped 32-bit Linux on armv7
   - macOS pre-built binaries require macOS 13.5+

3. **Behavioral Changes**
   - Stricter fetch() compliance
   - Enhanced AbortSignal validation
   - Stream/pipe errors now throw
   - Buffer behavior changes
   - Path handling fixes on Windows

### Impact Assessment for This Project

**Low Risk**: This project primarily consists of:

- Shell scripts for data collection
- No native C/C++ addons
- No complex Node.js dependencies
- Simple npm scripts for workflow automation

The upgrade should be straightforward with minimal to no code changes required.

## Changes Made

### 1. GitHub Actions Workflow

- Updated `.github/workflows/main-merge.yml` to use Node.js 24
- Changed `node-version: '20'` to `node-version: '24'`

### 2. Version Management Files

- Created `.nvmrc` with `24.11.0`
- Created `.node-version` with `24.11.0`
- These files enable automatic version switching with nvm or other Node.js version managers

### 3. Documentation

- Updated `README.md` with Node.js 24 LTS prerequisite
- Added installation instructions using nvm

## Local Upgrade Instructions

### Option 1: Using nvm (Recommended)

If you don't have nvm installed:

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell configuration
source ~/.zshrc  # or ~/.bash_profile for bash

# Install Node.js 24
nvm install 24

# Use Node.js 24
nvm use 24

# Set as default
nvm alias default 24
```

If you already have nvm:

```bash
# The .nvmrc file will automatically be detected
nvm install
nvm use
```

### Option 2: Direct Installation (macOS)

Using Homebrew:

```bash
# Update Homebrew
brew update

# Install Node.js 24
brew install node@24

# Link it
brew link node@24 --force --overwrite
```

Using the official installer:

1. Download from <https://nodejs.org/en/download/>
2. Install the macOS installer for v24.11.0 or later
3. Verify installation: `node --version`

## Testing

After upgrading your local Node.js version:

```bash
# Verify Node.js version
node --version
# Should output: v24.11.0 or higher

# Run project tests
npm test

# Test individual components
npm run test:workflows
npm run test:nfl:espn
```

## Current Test Results

Tests passed successfully with Node.js v22.12.0:

- ✅ All workflow tests passed
- ✅ All NFL ESPN download tests passed
- ✅ No breaking changes detected

## Rollback Plan

If issues arise:

### Using nvm

```bash
nvm use 22
nvm alias default 22
```

### Direct Installation

Reinstall Node.js v22 from <https://nodejs.org/en/download/>

### Revert Git Changes

```bash
git checkout main
git branch -D 2025.11.04/nodejs-v24-lts-upgrade
```

## Next Steps

1. ✅ Create upgrade branch
2. ✅ Update GitHub Actions workflow
3. ✅ Create version management files
4. ✅ Update README documentation
5. ✅ Test with current Node.js version
6. ⏳ Upgrade local Node.js to v24
7. ⏳ Test with Node.js v24
8. ⏳ Create pull request
9. ⏳ Merge and deploy

## Notes

- No Dockerfiles were found in this project, so no Docker image updates are needed
- The project has no `package-lock.json`, so no dependency updates are required
- All tests should continue to pass after the upgrade
- GitHub Actions will automatically use Node.js 24 after the PR is merged

## Support

For issues or questions:

- Node.js v24 Release Notes: <https://nodejs.org/en/blog/release/v24.0.0>
- Migration Guide: <https://nodejs.org/en/blog/migrations/v22-to-v24>
- Node.js LTS Schedule: <https://github.com/nodejs/release#release-schedule>
