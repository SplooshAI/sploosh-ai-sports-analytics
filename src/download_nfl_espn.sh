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
    # Don't exit here, let the caller decide what to do
}

# Fetch and validate JSON data from ESPN API
fetch_espn_data() {
    local game_id=$1
    local data
    data=$(curl -s "${API_BASE_URL}${game_id}")
    
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
    local date
    date=$(date +%Y%m%d)
    
    # Determine the NFL season based on current date
    # NFL seasons span two years (e.g., 2025-26)
    local year
    local month
    year=$(date +%Y)
    month=$(date +%m)
    
    # Determine the season directory in YYYY-YY format
    local season_dir
    if [ "$month" -ge 1 ] && [ "$month" -le 7 ]; then
        # For January-July, use previous year as start
        local prev_year=$((year-1))
        local curr_year_short=$((year % 100))
        # Ensure two-digit format for the second year
        if [ "$curr_year_short" -lt 10 ]; then
            curr_year_short="0${curr_year_short}"
        fi
        season_dir="${prev_year}-${curr_year_short}"
    else
        # For August-December, use current year as start
        local next_year_short=$((year + 1))
        next_year_short=$((next_year_short % 100))
        # Ensure two-digit format for the second year
        if [ "$next_year_short" -lt 10 ]; then
            next_year_short="0${next_year_short}"
        fi
        season_dir="${year}-${next_year_short}"
    fi
    
    # Create season directory if it doesn't exist
    mkdir -p "${DATA_BASE_DIR}/${season_dir}"

    # Create filename based on game type - away team first, then home team
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
        exit 1
    fi
    
    local filepath="${DATA_BASE_DIR}/${season_dir}/${filename}"

    echo "Downloading game data to ${filepath}..."
    if fetch_espn_data "${game_id}" | python3 -m json.tool > "$filepath"; then
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
    if [ $# -lt 5 ]; then
        echo "Error: Not enough arguments"
        usage
        exit 1
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
        exit 1
    fi

    echo "Downloading NFL game data for ${away_team} vs ${home_team} (${game_type})..."
    download_nfl_game "$game_id" "$away_team" "$home_team" "$game_type" "$week"
    echo "Done!"
}

# Execute main function with all arguments
main "$@"
