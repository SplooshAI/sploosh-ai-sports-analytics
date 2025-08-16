#!/bin/bash

# Download NFL game data from ESPN
# Usage:
# Download specific game:
# ./src/download_nfl_espn.sh GAMEID AWAY HOME [preseason|regular|playoffs] [week-number]
#
# Example for preseason:
# ./src/download_nfl_espn.sh 401547695 SEA KC preseason 1
#
# Example for regular season:
# ./src/download_nfl_espn.sh 401547800 SEA KC regular 3
#
# Example for playoffs:
# ./src/download_nfl_espn.sh 401548345 SEA KC playoffs "wild-card"

# Constants
readonly API_BASE_URL="https://cdn.espn.com/core/nfl/playbyplay?xhr=1&gameId="
readonly DATA_BASE_DIR="data/NFL - National Football League/espn"

# Function to print usage instructions
usage() {
    echo "Usage: $0 GAMEID AWAY HOME [preseason|regular|playoffs] [week-number]"
    echo "  GAMEID: ESPN game ID"
    echo "  AWAY: Away team abbreviation (e.g., SEA)"
    echo "  HOME: Home team abbreviation (e.g., KC)"
    echo "  GAME_TYPE: Game type (preseason, regular, playoffs)"
    echo "  WEEK: Week number or playoff round name"
    exit 1
}

# Fetch and validate JSON data from ESPN API
fetch_espn_data() {
    local game_id=$1
    local data=$(curl -s "${API_BASE_URL}${game_id}")
    
    if ! echo "$data" | jq -e . >/dev/null 2>&1; then
        echo "Error: Failed to get valid data for game ID ${game_id}"
        exit 1
    fi
        
    echo "$data"
}

# Function to download and save NFL game data
download_nfl_game() {
    local game_id=$1
    local away_team=$2
    local home_team=$3
    local game_type=$4
    local week=$5
    
    # Get current date in YYYYMMDD format
    local date=$(date +%Y%m%d)
    
    # Create directory if it doesn't exist
    mkdir -p "$DATA_BASE_DIR"

    # Create filename based on game type
    local filename
    if [ "$game_type" == "preseason" ]; then
        filename="${date}-${away_team}-vs-${home_team}-${game_id}-preseason-week-${week}.json"
    elif [ "$game_type" == "regular" ]; then
        filename="${date}-${away_team}-vs-${home_team}-${game_id}-week-${week}.json"
    elif [ "$game_type" == "playoffs" ]; then
        filename="${date}-${away_team}-vs-${home_team}-${game_id}-playoffs-${week}.json"
    else
        echo "Error: Invalid game type. Must be 'preseason', 'regular', or 'playoffs'."
        usage
    fi
    
    local filepath="${DATA_BASE_DIR}/${filename}"

    echo "Downloading game data to ${filepath}..."
    fetch_espn_data "${game_id}" | python3 -m json.tool > "$filepath"
    
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded game data to ${filepath}"
    else
        echo "Error: Failed to download game data"
        exit 1
    fi
}

# Main execution
main() {
    # Check if we have enough arguments
    if [ $# -lt 5 ]; then
        echo "Error: Not enough arguments"
        usage
    fi

    local game_id=$1
    local away_team=$2
    local home_team=$3
    local game_type=$4
    local week=$5

    # Validate game type
    if [[ "$game_type" != "preseason" && "$game_type" != "regular" && "$game_type" != "playoffs" ]]; then
        echo "Error: Game type must be 'preseason', 'regular', or 'playoffs'"
        usage
    fi

    echo "Downloading NFL game data for ${away_team} vs ${home_team} (${game_type})..."
    download_nfl_game "$game_id" "$away_team" "$home_team" "$game_type" "$week"
    echo "Done!"
}

# Execute main function with all arguments
main "$@"
