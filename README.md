# Welcome

This project explores working with a variety of APIs for sports data analysis and visualization.

## Prerequisites

- **Node.js**: v24.11.0 or higher (LTS)
  - The project uses Node.js 24 LTS, which is supported through April 2028
  - See the [Node.js v22 to v24 migration guide](https://nodejs.org/en/blog/migrations/v22-to-v24) for upgrade details
  - For detailed upgrade instructions, see [docs/UPGRADE_NODE_24.md](docs/UPGRADE_NODE_24.md)
  - Use [nvm](https://github.com/nvm-sh/nvm) to manage Node.js versions: `nvm install 24`
  - The project includes `.nvmrc` and `.node-version` files for automatic version switching

## Getting started

### Let's look at some sample data

Before considering tooling and software to review and analyze data, we need to find some meaningful data we want to work with.

Please review the overview of sample data locally available within this project at [data/README.md](data/README.md).

## Download data from supported sources

### Download MLB Game Data

The project includes scripts for downloading MLB game data from the MLB Stats API.

Make sure that `src/download_mlb.sh` is executable:

```bash
chmod +x src/download_mlb.sh
```

Available npm scripts:

- `npm run download:mariners` - Downloads the latest Mariners game data (ALDS Game 1 example)
- `npm run download:mlb:mariners` - Same as above
- `npm run download:mlb:regular` - Example for downloading regular season game data
- `npm run download:mlb:postseason` - Example for downloading postseason game data

To download data for a specific game, use the shell script directly:

```bash
# Regular season game
./src/download_mlb.sh GAMEID AWAY HOME regular

# Postseason game with description
./src/download_mlb.sh GAMEID AWAY HOME postseason "alds-game1"

# Examples:
./src/download_mlb.sh 745218 SF SEA regular
./src/download_mlb.sh 813058 DET SEA postseason "alds-game1"
```

### Download NFL Game Data

The project includes scripts for downloading NFL game data from ESPN.

Make sure that `src/download_nfl_espn.sh` is executable:

```bash
chmod +x src/download_nfl_espn.sh
```

Available npm scripts:

- `npm run download:nfl:espn` - Base script for downloading NFL game data
- `npm run download:nfl:espn:date` - Example for downloading specific game data

To download data for a specific game, use the shell script directly:

```bash
# Preseason game
./src/download_nfl_espn.sh GAMEID AWAY HOME preseason WEEK

# Regular season game
./src/download_nfl_espn.sh GAMEID AWAY HOME regular WEEK

# Playoff game
./src/download_nfl_espn.sh GAMEID AWAY HOME playoffs "round-name"

# Examples:
./src/download_nfl_espn.sh 401547716 SEA GB preseason 3
./src/download_nfl_espn.sh 401547800 SEA KC regular 3
./src/download_nfl_espn.sh 401548345 SEA KC playoffs "wild-card"
```

### Download NHL Game Data

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

### Get NHL Scores

The project includes a convenient script for fetching NHL game scores and copying them to your clipboard.

Make sure that `src/get_nhl_scores.sh` is executable:

```bash
chmod +x src/get_nhl_scores.sh
```

Available npm scripts:

- `npm run scores:nhl` - Fetches today's NHL scores and copies to clipboard
- `npm run scores:nhl:date` - Base script for fetching scores for a specific date

To fetch scores for a specific date or use additional options:

```bash
# Get today's scores (copies to clipboard)
./src/get_nhl_scores.sh

# Get scores for a specific date
./src/get_nhl_scores.sh 2025-11-19

# Display without copying to clipboard
./src/get_nhl_scores.sh --no-copy

# Get raw JSON output
./src/get_nhl_scores.sh 2025-11-19 --raw

# Show help
./src/get_nhl_scores.sh --help
```

The script provides:

- 🎨 Color-coded, formatted output with game status indicators
- 📋 Automatic clipboard copying (works with macOS, Linux)
- 🏒 Game summaries showing teams, scores, and times
- ⚙️ Flexible options for different use cases

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

- [Contributing Guidelines](./docs/CONTRIBUTING.md)
- [Testing Documentation](./.github/docs/TESTING.md)
- [Repository Setup](./.github/docs/SETUP.md) (for maintainers)
