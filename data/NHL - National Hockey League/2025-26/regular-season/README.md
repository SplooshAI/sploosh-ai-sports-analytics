# Seattle Kraken 2025-26 Regular Season

This directory contains play-by-play data for Seattle Kraken games during the 2025-26 NHL regular season.

## Data Format

Game files follow the naming pattern: `YYYYMMDD-AWAY-vs-HOME-<NHL_GAME_ID>.json`

Play-by-play data is accessed via the NHL API:
`https://api-web.nhle.com/v1/gamecenter/{GAME_ID}/play-by-play`

## Downloading Game Data

You can use the following npm scripts to download NHL game data:

```bash
# Download today's Kraken game
npm run download:nhl:kraken

# Download Kraken game for a specific date
npm run download:nhl:kraken:date -- YYYY-MM-DD
```

Or use the script directly:

```bash
# Download today's Kraken game
./src/download_nhl.sh kraken

# Download Kraken game for a specific date
./src/download_nhl.sh kraken 2025-10-09
```

## Regular Season Games

Play By Play:

- [GAME #01: 2025.10.09 Seattle WINS 3-1 against Anaheim (Season Opener)](./20251009-ANA-vs-SEA-2025020021.json)
