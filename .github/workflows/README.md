# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automating various tasks
in the Sploosh AI Sports Analytics project.

## Available Workflows

### 1. Semantic PR Check (`semantic-pr-check.yml`)

Validates that pull request titles follow the
[Conventional Commits](https://www.conventionalcommits.org/) format.

**Triggers:**

- Pull request opened
- Pull request title edited
- New commits pushed to PR

**Features:**

- Enforces semantic versioning format in PR titles
- Provides helpful error messages for invalid formats
- Detects breaking changes with `!` notation

### 2. Main Branch Merge (`main-merge.yml`)

Handles version bumping after merges to the main branch.

**Triggers:**

- Push to main branch
- Manual workflow dispatch

**Features:**

- Automatically determines version bump type based on commit message
- Creates a new branch for version bump
- Updates version in package.json
- Creates a pull request with the version bump
- Automatically merges the PR when checks pass

### 3. Shell Script Tests (`shell-script-test.yml`)

Tests shell scripts in the `src` directory.

**Triggers:**

- Push to main branch (when shell scripts change)
- Pull request to main branch (when shell scripts change)
- Manual workflow dispatch

**Features:**

- Runs ShellCheck on all shell scripts
- Tests scripts in help mode
- Provides debug information when needed

### 4. GHCR Cleanup (`cleanup_ghcr.yml`)

Cleans up old container images from GitHub Container Registry.

**Triggers:**

- Monthly schedule (first day of month)
- Manual workflow dispatch

**Features:**

- Configurable retention policy
- Dry run mode for testing
- Detailed reporting in GitHub Actions summary

## Testing Workflows Locally

We use [act](https://github.com/nektos/act) to test GitHub Actions workflows locally.

```sh
# Install act using Homebrew
brew install act

# Test semantic PR check
npm run test:workflows:semantic

# Test all workflows
npm run test:workflows
```

## Workflow Development Guidelines

1. **Idempotency**: Ensure workflows can be run multiple times without side effects
2. **Error Handling**: Include proper error handling and reporting
3. **Documentation**: Update this README when adding or modifying workflows
4. **Testing**: Test workflows locally with `act` before pushing
5. **Security**: Use appropriate permissions for each job

## Related Documentation

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [ShellCheck](https://www.shellcheck.net/)
