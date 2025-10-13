# Welcome

This directory contains example data files to explore [MLB](https://www.mlb.com) ([Major League Baseball](https://www.mlb.com)) data.

## Major League Baseball (MLB)

This endpoint is publicly-available and can be accessed by obtaining the game ID from the MLB scoreboard.

Example data is contained in files matching the pattern `YYYYMMDD-visiting-vs-home-<MLB_GAME_ID>.json` from the MLB API.

### 2025 Postseason

#### ALDS Game 1 - October 4th, 2025: Detroit Tigers @ Seattle Mariners

- **Final Score:** Tigers 3, Mariners 2 (11 innings - extra innings)
- Game URL: [https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/04/813058](https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/04/813058)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813058/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813058/feed/live?language=en)
  - [./2025/20251004-DET-vs-SEA-813058-alds-game1.json](./2025/20251004-DET-vs-SEA-813058-alds-game1.json)

#### ALDS Game 2 - October 5th, 2025: Detroit Tigers @ Seattle Mariners

- **Final Score:** Mariners 3, Tigers 2
- Game URL: [https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/05/813057](https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/05/813057)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813057/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813057/feed/live?language=en)
  - [./2025/20251005-DET-vs-SEA-813057-alds-game2.json](./2025/20251005-DET-vs-SEA-813057-alds-game2.json)

#### ALDS Game 3 - October 7th, 2025: Seattle Mariners @ Detroit Tigers

- **Final Score:** Mariners 8, Tigers 4
- Game URL: [https://www.mlb.com/gameday/mariners-vs-tigers/2025/10/07/813056](https://www.mlb.com/gameday/mariners-vs-tigers/2025/10/07/813056)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813056/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813056/feed/live?language=en)
  - [./2025/20251007-SEA-vs-DET-813056-alds-game3.json](./2025/20251007-SEA-vs-DET-813056-alds-game3.json)

#### ALDS Game 4 - October 8th, 2025: Seattle Mariners @ Detroit Tigers

- **Final Score:** Tigers 9, Mariners 3
- Game URL: [https://www.mlb.com/gameday/mariners-vs-tigers/2025/10/08/813055](https://www.mlb.com/gameday/mariners-vs-tigers/2025/10/08/813055)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813055/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813055/feed/live?language=en)
  - [./2025/20251008-SEA-vs-DET-813055-alds-game4.json](./2025/20251008-SEA-vs-DET-813055-alds-game4.json)

#### ALDS Game 5 - October 10th, 2025: Detroit Tigers @ Seattle Mariners

- **Final Score:** Mariners 3, Tigers 2 (15 innings - extra innings)
- Game URL: [https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/10/813054](https://www.mlb.com/gameday/tigers-vs-mariners/2025/10/10/813054)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813054/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813054/feed/live?language=en)
  - [./2025/20251010-DET-vs-SEA-813054-alds-game5.json](./2025/20251010-DET-vs-SEA-813054-alds-game5.json)

#### ALCS Game 1 - October 12th, 2025: Seattle Mariners @ Toronto Blue Jays

- **Final Score:** Mariners 3, Blue Jays 1
- Game URL: [https://www.mlb.com/gameday/mariners-vs-blue-jays/2025/10/12/813040](https://www.mlb.com/gameday/mariners-vs-blue-jays/2025/10/12/813040)
- GET [https://ws.statsapi.mlb.com/api/v1.1/game/813040/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/813040/feed/live?language=en)
  - [./2025/20251012-SEA-vs-TOR-813040-alcs-game1.json](./2025/20251012-SEA-vs-TOR-813040-alcs-game1.json)

### 2024 Regular Season

Example scoreboard URL for the 2024.08.24 game between SF and SEA is [https://www.mlb.com/gameday/giants-vs-mariners/2024/08/24/745218/final/wrap](https://www.mlb.com/gameday/giants-vs-mariners/2024/08/24/745218/final/wrap):

- GET [https://ws.statsapi.mlb.com/api/v1.1/game/745218/feed/live?language=en](https://ws.statsapi.mlb.com/api/v1.1/game/745218/feed/live?language=en)
  - [./2024/20240824-SF-vs-SEA-745218.json](./2024/20240824-SF-vs-SEA-745218.json)
