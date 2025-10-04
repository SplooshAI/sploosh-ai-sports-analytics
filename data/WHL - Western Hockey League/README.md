# Welcome

This directory contains example data files to explore [WHL](https://chl.ca/whl/) ([Western Hockey League](https://chl.ca/whl/)) data.

## Western Hockey League (WHL)

Example data is contained in files matching the pattern `YYYYMMDD-visiting-vs-home-<WHL_GAME_ID>-<game_type>-<tab>.json` from the WHL API.

For the first regular season game of the 2024-25 season for the Seattle Thunderbirds (WHL game ID `1021522`):

Game Summary - <https://cluster.leaguestat.com/feed/index.php?feed=gc&game_id=1021522&key=41b145a848f4bd67&client_code=whl&lang_code=en&fmt=json&tab=gamesummary>

Play By Play - <https://cluster.leaguestat.com/feed/index.php?feed=gc&game_id=1021522&key=41b145a848f4bd67&client_code=whl&lang_code=en&fmt=json&tab=pxpverbose>

## Downloading WHL Game Data

We use a unified script for downloading all types of WHL game data (preseason, regular season, and playoffs). The script automatically detects the game type and saves the data in the appropriate directory.

### Usage

You can use the following npm scripts to download WHL game data:

```bash
# Download today's game (auto-detects game type)
npm run download:whl:game

# Download game for a specific date
npm run download:whl:game:date

# Download preseason game for a specific date
npm run download:whl:game:preseason

# Download regular season game for a specific date
npm run download:whl:game:regular

# Download playoff game for a specific date
npm run download:whl:game:playoff

# Download games for multiple dates
npm run download:whl:game:multiple
```

Or you can use the script directly:

```bash
# Download today's game (auto-detects game type)
./src/download_whl_game.sh

# Download game for a specific date
./src/download_whl_game.sh 2025-09-05

# Download game for a specific date with game type
./src/download_whl_game.sh 2025-09-05 preseason

# Download games for multiple dates
./src/download_whl_game.sh 2025-09-02 2025-09-05
```

### Seattle Thunderbirds 2024-25

#### Regular Season

Play By Play:

- [GAME #01: 2024.09.20 Seattle loses 4-3 against Vancouver in OT](./2024-25/regular-season/20240920-SEA-vs-VAN-1021208-pxpverbose.json)
- [GAME #02: 2024.09.21 Seattle loses 7-1 against Wenatchee](./2024-25/regular-season/20240921-SEA-vs-WEN-1021219-pxpverbose.json)
- [GAME #03: 2024.09.27 Seattle loses 5-3 against Kamloops](./2024-25/regular-season/20240927-SEA-vs-KAM-1021220-pxpverbose.json)
- [GAME #04: 2024.09.28 Seattle WINS 5-4 against Wenatchee in OT](./2024-25/regular-season/20240928-WEN-vs-SEA-1021233-pxpverbose.json)
- [GAME #05: 2024.10.04 Seattle loses 5-2 against Prince George](./2024-25/regular-season/20241004-PG-vs-SEA-1021246-pxpverbose.json)
- [GAME #06: 2024.10.05 Seattle loses 7-2 against Spokane](./2024-25/regular-season/20241005-SEA-vs-SPO-1021256-pxpverbose.json)
- [GAME #07: 2024.10.08 Seattle WINS 5-2 against Tri-City](./2024-25/regular-season/20241008-TC-vs-SEA-1021264-pxpverbose.json)
- [GAME #08: 2024.10.11 Seattle WINS 3-1 against Kamloops](./2024-25/regular-season/20241011-KAM-vs-SEA-1021276-pxpverbose.json)
- [GAME #09: 2024.10.12 Seattle WINS 6-5 against Portland](./2024-25/regular-season/20241012-POR-vs-SEA-1021283-pxpverbose.json)
- [GAME #10: 2024.10.18 Seattle loses 4-1 against Brandon](./2024-25/regular-season/20241018-SEA-vs-BDN-1021300-pxpverbose.json)
- [GAME #11: 2024.10.19 Seattle loses 8-0 against Regina](./2024-25/regular-season/20241019-SEA-vs-REG-1021310-pxpverbose.json)
- [GAME #12: 2024.10.22 Seattle WINS 4-1 against Moose Jaw](./2024-25/regular-season/20241022-SEA-vs-MJ-1021318-pxpverbose.json)
- [GAME #13: 2024.10.23 Seattle loses 5-1 against Saskatoon](./2024-25/regular-season/20241023-SEA-vs-SAS-1021322-pxpverbose.json)
- [GAME #14: 2024.10.25 Seattle loses 4-3 against Prince Albert](./2024-25/regular-season/20241025-SEA-vs-PA-1021326-pxpverbose.json)
- [GAME #15: 2024.10.26 Seattle loses 7-4 against Swift Current](./2024-25/regular-season/20241026-SEA-vs-SC-1021341-pxpverbose.json)
- [GAME #16: 2024.11.01 Seattle loses 5-4 against Edmonton in SO](./2024-25/regular-season/20241101-EDM-vs-SEA-1021354-pxpverbose.json)
- [GAME #17: 2024.11.02 Seattle loses 5-2 against Portland](./2024-25/regular-season/20241102-POR-vs-SEA-1021361-pxpverbose.json)
- [GAME #18: 2024.11.08 Seattle loses 4-3 against Calgary in OT](./2024-25/regular-season/20241108-CGY-vs-SEA-1021381-pxpverbose.json)
- [GAME #19: 2024.11.09 Seattle loses 5-2 against Victoria](./2024-25/regular-season/20241109-VIC-vs-SEA-1021389-pxpverbose.json)
- [GAME #20: 2024.11.12 Seattle WINS 3-2 against Red Deer in SO](./2024-25/regular-season/20241112-RD-vs-SEA-1021400-pxpverbose.json)
- [GAME #21: 2024.11.13 Seattle loses 5-3 against Kelowna](./2024-25/regular-season/20241113-SEA-vs-KEL-1021402-pxpverbose.json)
- [GAME #22: 2024.11.16 Seattle loses 5-2 against Everett](./2024-25/regular-season/20241116-EVT-vs-SEA-1021418-pxpverbose.json)
- [GAME #23: 2024.11.23 Seattle WINS 5-3 against Lethbridge in SO](./2024-25/regular-season/20241123-LET-vs-SEA-1021446-pxpverbose.json)
- [GAME #24: 2024.11.27 Seattle WINS 3-2 against Wenatchee in SO](./2024-25/regular-season/20241127-WEN-vs-SEA-1021455-pxpverbose.json)
- [GAME #25: 2024.11.29 Seattle WINS 3-2 against Victoria in SO](./2024-25/regular-season/20241129-SEA-vs-VIC-1021465-pxpverbose.json)
- [GAME #26: 2024.11.30 Seattle loses 6-1 against Victoria](./2024-25/regular-season/20241130-SEA-vs-VIC-1021476-pxpverbose.json)
- [GAME #27: 2024.12.01 Seattle loses 5-2 against Vancouver](./2024-25/regular-season/20241201-SEA-vs-VAN-1021480-pxpverbose.json)
- [GAME #28: 2024.12.06 Seattle WINS 5-2 against Kamloops](./2024-25/regular-season/20241206-SEA-vs-KAM-1021489-pxpverbose.json)
- [GAME #29: 2024.12.07 Seattle loses 4-1 against Everett](./2024-25/regular-season/20241207-SEA-vs-EVT-1021497-pxpverbose.json)
- [GAME #30: 2024.12.08 Seattle loses 3-1 against Spokane](./2024-25/regular-season/20241208-SPO-vs-SEA-1021507-pxpverbose.json)
- [GAME #31: 2024.12.10 Seattle wins 7-3 against Wenatchee](./2024-25/regular-season/20241210-WEN-vs-SEA-1021512-pxpverbose.json)
- [GAME #32: 2024.12.13 Seattle loses 4-3 against Spokane](./2024-25/regular-season/20241213-SPO-vs-SEA-1021522-pxpverbose.json)
- [GAME #33: 2024.12.14 Seattle loses 5-2 against Portland](./2024-25/regular-season/20241214-SEA-vs-POR-1021529-pxpverbose.json)
- [GAME #34: 2024.12.27 Seattle loses 5-3 against Everett](./2024-25/regular-season/20241227-EVT-vs-SEA-1021553-pxpverbose.json)
- [GAME #35: 2024.12.28 Seattle loses 6-1 against Everett](./2024-25/regular-season/20241228-SEA-vs-EVT-1021556-pxpverbose.json)
- [GAME #36: 2024.12.31 Seattle loses 6-4 against Prince George](./2024-25/regular-season/20241231-PG-vs-SEA-1021574-pxpverbose.json)
- [GAME #37: 2025.01.03 Seattle wins 3-1 against Prince George](./2024-25/regular-season/20250103-SEA-vs-PG-1021587-pxpverbose.json)
- [GAME #38: 2025.01.04 Seattle loses 3-0 against Prince George](./2024-25/regular-season/20250104-SEA-vs-PG-1021601-pxpverbose.json)
- [GAME #39: 2025.01.07 Seattle loses 4-1 against Victoria](./2024-25/regular-season/20250107-VIC-vs-SEA-1021611-pxpverbose.json)
- [GAME #40: 2025.01.10 Seattle loses 6-5 against Tri-City](./2024-25/regular-season/20250110-SEA-vs-TC-1021625-pxpverbose.json)
- [GAME #41: 2025.01.11 Seattle wins 5-4 against Everett in SO](./2024-25/regular-season/20250111-EVT-vs-SEA-1021632-pxpverbose.json)
- [GAME #42: 2025.01.17 Seattle wins 4-3 against Kelowna in OT](./2024-25/regular-season/20250117-SEA-vs-KEL-1021647-pxpverbose.json)
- [GAME #43: 2025.01.18 Seattle loses 5-2 against Kelowna](./2024-25/regular-season/20250118-KEL-vs-SEA-1021660-pxpverbose.json)
- [GAME #44: 2025.01.21 Seattle wins 7-1 against Vancouver](./2024-25/regular-season/20250121-VAN-vs-SEA-1021671-pxpverbose.json)
- [GAME #45: 2025.01.24 Seattle wins 4-1 against Victoria](./2024-25/regular-season/20250124-VIC-vs-SEA-1021682-pxpverbose.json)
- [GAME #46: 2025.01.25 Seattle loses 6-1 against Everett](./2024-25/regular-season/20250125-SEA-vs-EVT-1021685-pxpverbose.json)
- [GAME #47: 2025.01.31 Seattle wins 5-2 against Vancouver](./2024-25/regular-season/20250131-VAN-vs-SEA-1021715-pxpverbose.json)
- [GAME #48: 2025.02.01 Seattle wins 4-3 against Medicine Hat in eleven round SO](./2024-25/regular-season/20250201-MH-vs-SEA-1021725-pxpverbose.json)
- [GAME #49: 2025.02.07 Seattle loses 9-1 against Spokane](./2024-25/regular-season/20250207-SPO-vs-SEA-1021745-pxpverbose.json)
- [GAME #50: 2025.02.08 Seattle wins 4-3 against Portland](./2024-25/regular-season/20250208-SEA-vs-POR-1021752-pxpverbose.json)
- [GAME #51: 2025.02.11 Seattle wins 3-2 against Kelowna](./2024-25/regular-season/20250211-KEL-vs-SEA-1021762-pxpverbose.json)
- [GAME #52: 2025.02.15 Seattle wins 4-2 against Portland](./2024-25/regular-season/20250215-POR-vs-SEA-1021784-pxpverbose.json)
- [GAME #53: 2025.02.16 Seattle wins 4-0 against Wenatchee](./2024-25/regular-season/20250216-SEA-vs-WEN-1021788-pxpverbose.json)
- [GAME #54: 2025.02.17 Seattle loses 4-3 against Portland](./2024-25/regular-season/20250217-SEA-vs-POR-1021793-pxpverbose.json)
- [GAME #55: 2025.02.21 Seattle loses 2-1 against Wenatchee in OT](./2024-25/regular-season/20250221-SEA-vs-WEN-1021812-pxpverbose.json)
- [GAME #56: 2025.02.22 Seattle wins 3-1 against Everett](./2024-25/regular-season/20250222-EVT-vs-SEA-1021817-pxpverbose.json)
- [GAME #57: 2025.02.28 Seattle loses 2-1 against Everett](./2024-25/regular-season/20250228-SEA-vs-EVT-1021835-pxpverbose.json)
- [GAME #58: 2025.03.01 Seattle wins 6-3 against Spokane](./2024-25/regular-season/20250301-SEA-vs-SPO-1021850-pxpverbose.json)
- [GAME #59: 2025.03.02 Seattle loses 2-1 against Tri-Cities](./2024-25/regular-season/20250302-TC-vs-SEA-1021856-pxpverbose.json)
- [GAME #60: 2025.03.04 Seattle loses 3-2 against Kamloops](./2024-25/regular-season/20250304-KAM-vs-SEA-1021861-pxpverbose.json)
- [GAME #61: 2025.03.07 Seattle wins 7-2 against Portland](./2024-25/regular-season/20250307-SEA-vs-POR-1021871-pxpverbose.json)
- [GAME #62: 2025.03.08 Seattle loses 4-1 against Portland](./2024-25/regular-season/20250308-POR-vs-SEA-1021882-pxpverbose.json)
- [GAME #64: 2025.03.14 Seattle wins 6-3 vs Tri-Cities](./2024-25/regular-season/20250314-TC-vs-SEA-1021904-pxpverbose.json)
- [GAME #65: 2025.03.15 Seattle loses 6-1 against Portland](./2024-25/regular-season/20250315-SEA-vs-POR-1021912-pxpverbose.json)
- [GAME #66: 2025.03.16 Seattle wins 5-1 against Tri-Cities](./2024-25/regular-season/20250316-SEA-vs-TC-1021921-pxpverbose.json)
- [GAME #67: 2025.03.21 Seattle wins 7-6 against Spokane in SO](./2024-25/regular-season/20250321-SEA-vs-SPO-1021936-pxpverbose.json)
- [GAME #68: 2025.03.22 Seattle wins 5-4 against Portland](./2024-25/regular-season/20250322-POR-vs-SEA-1021943-pxpverbose.json)
- [GAME #63: 2025.03.11/2025.03.23 Seattle wins 3-2 against Tri-Cities (completion of postponed game)](./2024-25/regular-season/20250323-SEA-vs-TC-1021891-pxpverbose.json)

### 2024-25 Playoffs

- [ROUND 1 GAME #1: 2025.03.28 Seattle wins 3-2 against Everett Silvertips](./2024-25/playoffs/20250328-SEA-vs-EVT-1021961-pxpverbose.json)
- [ROUND 1 GAME #2: 2025.03.29 Seattle loses 3-2 against Everett Silvertips in OT](./2024-25/playoffs/20250329-SEA-vs-EVT-1021962-pxpverbose.json)
- [ROUND 1 GAME #3: 2025.04.01 Seattle wins 6-3 against Everett Silvertips](./2024-25/playoffs/20250401-EVT-vs-SEA-1021969-pxpverbose.json)
- [ROUND 1 GAME #4: 2025.04.04 Seattle loses 6-2 against Everett Silvertips](./2024-25/playoffs/20250404-EVT-vs-SEA-1021970-pxpverbose.json)
- [ROUND 1 GAME #5: 2025.04.05 Seattle loses 7-4 against Everett Silvertips](./2024-25/playoffs/20250405-SEA-vs-EVT-1021971-pxpverbose.json)
- [ROUND 1 GAME #6: 2025.04.07 Seattle loses 1-0 against Everett Silvertips in OT2](./2024-25/playoffs/20250407-EVT-vs-SEA-1021972-pxpverbose.json)

### 2025-26 Preseason

- [PRESEASON GAME #1: 2025.09.02 Seattle loses 8-0 against EVT](./2025-26/preseason/20250902-EVT-vs-SEA-1022070-pxpverbose.json)
- [PRESEASON GAME #2: 2025.09.05 Seattle loses 9-3 against SPO](./2025-26/preseason/20250905-SPO-vs-SEA-1022082-pxpverbose.json)
- [PRESEASON GAME #3: 2025.09.06 Seattle wins 7-4 against EVT](./2025-26/preseason/20250906-SEA-vs-EVT-1022086-pxpverbose.json)
- [PRESEASON GAME #4: 2025.09.07 Seattle loses 5-4 against POR](./2025-26/preseason/20250907-SEA-vs-POR-1022096-pxpverbose.json)
- [PRESEASON GAME #5: 2025.09.12 Seattle loses 4-0 against SPO at Toyota Arena - Kennewick, WA](./2025-26/preseason/20250912-SPO-vs-SEA-1022111-preseason-pxpverbose.json)
- [PRESEASON GAME #6: 2025.09.13 Seattle loses 4-3 against PEN at Toyota Arena - Kennewick, WA](./2025-26/preseason/20250913-PEN-vs-SEA-1022119-preseason-pxpverbose.json)

**[View complete 2025-26 Preseason Analysis and Regular Season Preview](./2025-26/preseason/ANALYSIS.md)**

### 2025-26 Regular Season

- [GAME #01: 2025.09.20 Seattle wins 6-3 against TC](./2025-26/20250920-TC-vs-SEA-1022142-pxpverbose.json)
- [GAME #02: 2025.09.26 Seattle loses 4-3 against KAM](./2025-26/20250926-SEA-vs-KAM-1022144-pxpverbose.json)
- [GAME #03: 2025.09.27 Seattle loses 6-0 against KAM](./2025-26/20250927-SEA-vs-KAM-1022152-pxpverbose.json)
- [GAME #04: 2025.10.03 Seattle wins 7-4 against KAM](./2025-26/20251003-KAM-vs-SEA-1022167-pxpverbose.json)
