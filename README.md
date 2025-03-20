# Welcome

This project explores working with a variety of APIs for sports data analysis and visualization.

## Getting started

### Let's look at some sample data

Before considering tooling and software to review and analyze data, we need to find some meaningful data we want to work with.

Please review the overview of sample data locally available within this project at [data/README.md](data/README.md).

## Download data from supported sources

### EXAMPLE: Download NHL Game Data

Please note that functionality exists to download Seattle Kraken NHL data as of this writing (Monday, January 6th, 2025).

Make sure that `src/download_nhl.sh` is executable:

```bash
chmod +x src/download_nhl.sh
```

The project includes several scripts for downloading NHL game data:

- `npm run download:kraken` - Downloads Kraken game data for the current date
- `npm run download:nhl:kraken` - Downloads Kraken game data for the current date
- `npm run download:nhl:kraken:date` - Example to demonstrate how to download Kraken game data for YYYY-MM-DD

To download data for a specific date, you can modify the date in `package.json` or use the shell script directly:

```bash
./src/download_nhl.sh kraken YYYY-MM-DD
```

### EXAMPLE: Download WHL Game Data

Please note that functionality exists to download Seattle Kraken NHL data as of this writing (Monday, January 6th, 2025).

Make sure that `src/download_whl.sh` is executable:

```bash
chmod +x src/download_whl.sh
```

The project includes several scripts for downloading NHL game data:

- `npm run download:tbirds` - Downloads Kraken game data for the current date
- `npm run download:whl:tbirds` - Downloads Kraken game data for the current date
- `npm run download:whl:tbirds:date` - Example to demonstrate how to download Kraken game data for YYYY-MM-DD

To download data for a specific date, you can modify the date in `package.json` or use the shell script directly:

```bash
./src/download_whl.sh thunderbirds YYYY-MM-DD
```

## Testing GitHub Actions Locally

We recommend using [act](https://github.com/nektos/act) to test GitHub Actions workflows locally before pushing changes if you are developing on a Mac.

The application does not have to be running in Docker to test the workflows, but Docker Desktop must be running for the act tests to run and spin up the necessary containers.

Prerequisites for macOS

- Homebrew
- Docker Desktop (must be running)

```sh
# Install act using Homebrew
brew install act

# Verify installation
act --version # Should show 0.2.74 or higher

```

### Running Tests

The following test scripts are available:

1. `npm run test`
   - Primary test command
   - Runs all workflow tests via test:workflows
   - Recommended for general testing

2. `npm run test:workflows`
   - Runs all workflow tests in sequence
   - Tests PR title validation and version bumping
   - Provides detailed feedback

3. `npm run test:workflows:semantic`
   - Tests PR title validation only (using minor version example)
   - Validates against conventional commit format

4. `npm run test:workflows:semantic:major`
   - Tests PR title validation with breaking change
   - Validates major version bump detection

5. `npm run test:workflows:semantic:minor`
   - Tests PR title validation with new feature
   - Validates minor version bump detection

6. `npm run test:workflows:semantic:patch`
   - Tests PR title validation with bug fix
   - Validates patch version bump detection

7. `npm run test:workflows:semantic:invalid`
   - Tests PR title validation with invalid format
   - Verifies rejection of non-compliant PR titles

8. `npm run test:workflows:version`
   - Tests version bump workflow
   - Note: Git operations will fail locally (expected)

9. `npm run test:workflows:merge`
   - Tests main branch merge workflow
   - Simulates PR merge and version bump process
   - Note: Git operations will fail locally (expected)

#### Expected Test Results

1. Semantic PR Check Tests:
   - All tests should pass except "invalid" test
   - Invalid PR format test should fail with clear error

2. Version Bump Tests:
   - Will show git authentication errors (expected)
   - These workflows can only be fully tested in GitHub Actions

3. Merge Tests:
   - Will show authentication errors locally (expected)
   - Tests workflow syntax and merge logic
   - Full functionality requires GitHub Actions environment

## Development Guidelines

- **Version Control**: We use semantic versioning with automated version bumps
- **Commit Signing**: All commits must be GPG signed
- **Pull Requests**: PR titles must follow conventional commit format

For detailed guidelines, see:

- [Contributing Guidelines](./CONTRIBUTING.md)
- [Testing Documentation](./.github/docs/TESTING.md)
- [Repository Setup](./.github/docs/SETUP.md) (for maintainers)
