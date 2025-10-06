# Welcome

This directory contains example data files to explore [MLB](https://www.mlb.com) ([Major League Baseball](https://www.mlb.com)) data.

## Major League Baseball (MLB)

This endpoint is publicly-available and can be accessed by obtaining the game ID from the MLB scoreboard.

Example data is contained in files matching the pattern `YYYYMMDD-visiting-vs-home-<MLB_GAME_ID>.json` from the MLB API.

### 2025 Postseason

#### ALDS Game 1 - October 4th, 2025: Detroit Tigers @ Seattle Mariners

- **Final Score:** Tigers 3, Mariners 2 (11 innings)
- Game URL: [https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/04/813058](https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/04/813058)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813058/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813058/feed/live?language=en)
  - [./2025/20251004-DET-vs-SEA-813058-alds-game1.json](./2025/20251004-DET-vs-SEA-813058-alds-game1.json)

#### ALDS Game 2 - October 5th, 2025: Detroit Tigers @ Seattle Mariners

- **Final Score:** Mariners 3, Tigers 2
- Game URL: [https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/05/813057](https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/05/813057)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813057/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813057/feed/live?language=en)
  - [./2025/20251005-DET-vs-SEA-813057-alds-game2.json](./2025/20251005-DET-vs-SEA-813057-alds-game2.json)

### 2024 Regular Season

Example scoreboard URL for the 2024.08.24 game between SF and SEA is [https://www.mlb.com/gameday/giants-vs-mariners/2024/08/24/745218/final/wrap](https://www.mlb.com/gameday/giants-vs-mariners/2024/08/24/745218/final/wrap):

- GET [https://ws.statsapi.mlb.com/api/v1.1/game/745218/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/745218/feed/live?language=en)
  - [./2024/20240824-SF-vs-SEA-745218.json](./2024/20240824-SF-vs-SEA-745218.json)
