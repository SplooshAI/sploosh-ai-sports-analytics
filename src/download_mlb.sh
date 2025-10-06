#!/bin/bash

# Download MLB game data from MLB Stats API
# Usage:
# Download specific game:
# ./src/download_mlb.sh GAMEID AWAY HOME [regular|postseason] [optional-description]
#
# Example for regular season:
# ./src/download_mlb.sh 745218 SF SEA regular
#
# Example for postseason:
# ./src/download_mlb.sh 813058 DET SEA postseason "alds-game1"
#
# Example for World Series:
# ./src/download_mlb.sh 123456 NYY LAD postseason "world-series-game7"

# Constants
readonly API_BASE_URL="https://ws.statsapi.mlb.com/api/v1.1/game"
readonly DATA_BASE_DIR="data/MLB - Major League Baseball"

# Function to print usage instructions
usage() {
    echo "Usage: $0 GAMEID AWAY HOME [regular|postseason] [optional-description]"
    echo "  GAMEID: MLB game ID"
    echo "  AWAY: Away team abbreviation (e.g., DET)"
    echo "  HOME: Home team abbreviation (e.g., SEA)"
    echo "  GAME_TYPE: Game type (regular, postseason)"
    echo "  DESCRIPTION: Optional description for postseason games (e.g., alds-game1, world-series-game7)"
    # Don't exit here, let the caller decide what to do
}

# Fetch and validate JSON data from MLB API
fetch_mlb_data() {
    local game_id=$1
    local data
    data=$(curl -s "${API_BASE_URL}/${game_id}/feed/live?language=en")
    
    if ! echo "$data" | jq -e . >/dev/null 2>&1; then
        echo "Error: Failed to get valid data for game ID ${game_id}"
        exit 1
    fi
        
    echo "$data"
}

# Function to download and save MLB game data
download_mlb_game() {
    local game_id=$1
    local away_team=$2
    local home_team=$3
    local game_type=$4
    local description=$5
    
    # Get game data first to extract the game date
    local game_data
    game_data=$(fetch_mlb_data "${game_id}")
    
    # Extract game date from the API response
    local game_datetime
    game_datetime=$(echo "$game_data" | jq -r '.gameData.datetime.officialDate')
    
    echo "Extracting game date from API response: $game_datetime"
    
    if [ -z "$game_datetime" ] || [ "$game_datetime" = "null" ]; then
        echo "Error: Could not extract game date from API response. Using current date as fallback."
        game_date=$(date +%Y%m%d)
    else
        # MLB provides dates in YYYY-MM-DD format
        # Remove hyphens to get YYYYMMDD
        game_date=$(echo "$game_datetime" | tr -d '-')
        echo "Successfully extracted date: $game_date from $game_datetime"
    fi
    
    # Use game date for filename
    local date=$game_date
    
    # Determine the MLB season (year)
    local year=${game_date:0:4}
    
    echo "Using date: $game_date (Year: $year) for file naming"
    
    # Create season directory if it doesn't exist
    mkdir -p "${DATA_BASE_DIR}/${year}"

    # Create filename based on game type - away team first, then home team
    local filename
    if [ "$game_type" == "regular" ]; then
        filename="${date}-${away_team}-vs-${home_team}-${game_id}.json"
    elif [ "$game_type" == "postseason" ]; then
        if [ -n "$description" ]; then
            filename="${date}-${away_team}-vs-${home_team}-${game_id}-${description}.json"
        else
            filename="${date}-${away_team}-vs-${home_team}-${game_id}-postseason.json"
        fi
    else
        echo "Error: Invalid game type. Must be 'regular' or 'postseason'."
        usage
        exit 1
    fi
    
    local filepath="${DATA_BASE_DIR}/${year}/${filename}"

    echo "Downloading game data to ${filepath}..."
    if fetch_mlb_data "${game_id}" | python3 -m json.tool > "$filepath"; then
        echo "Successfully downloaded game data to ${filepath}"
    else
        echo "Error: Failed to download game data"
        exit 1
    fi
}

# Main execution
main() {
    # Check for help flag
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        usage
        exit 0
    fi

    # Check if we have enough arguments
    if [ $# -lt 4 ]; then
        echo "Error: Not enough arguments"
        usage
        exit 1
    fi

    local game_id=$1
    local away_team=$2
    local home_team=$3
    local game_type=$4
    local description=$5

    # Validate game type
    if [[ "$game_type" != "regular" && "$game_type" != "postseason" ]]; then
        echo "Error: Game type must be 'regular' or 'postseason'"
        usage
        exit 1
    fi

    echo "Downloading MLB game data for ${away_team} vs ${home_team} (${game_type})..."
    download_mlb_game "$game_id" "$away_team" "$home_team" "$game_type" "$description"
    echo "Done!"
}

# Execute main function with all arguments
main "$@"
