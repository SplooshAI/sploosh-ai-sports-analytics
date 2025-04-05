#!/bin/bash

# Download WHL playoff game data
# This script downloads WHL playoff game data for a specified date
# Usage: ./download_whl_playoff_game.sh [YYYY-MM-DD]
# If no date is provided, today's date will be used

# Constants
readonly API_KEY="41b145a848f4bd67"
readonly DATA_BASE_DIR="data/WHL - Western Hockey League"
readonly SEASON="2024-25"
readonly PLAYOFFS_DIR="${DATA_BASE_DIR}/${SEASON}/playoffs"
readonly THUNDERBIRDS_TEAM_ID=214  # Seattle Thunderbirds team ID

# Function to print usage instructions
usage() {
    echo "Usage: $0 [date]"
    echo "  date: Optional date in YYYY-MM-DD format (defaults to today)"
    exit 1
}

# Function to log messages
log_message() {
    echo "$1" >&2
}

# Function to log errors
log_error() {
    echo "Error: $1" >&2
}

# Function to validate date format
validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        log_error "Invalid date format. Please use YYYY-MM-DD"
        return 1
    fi
    
    # Additional validation
    local year=${date:0:4}
    local month=${date:5:2}
    local day=${date:8:2}
    
    if [ "$month" -lt 1 ] || [ "$month" -gt 12 ] || [ "$day" -lt 1 ] || [ "$day" -gt 31 ]; then
        log_error "Invalid date values. Month must be 1-12, Day must be 1-31"
        return 1
    fi
    
    return 0
}

# Function to fetch and validate JSON data from WHL API
fetch_whl_data() {
    local game_id=$1
    local tab=$2
    local url="https://cluster.leaguestat.com/feed/index.php?feed=gc&game_id=${game_id}&key=${API_KEY}&client_code=whl&lang_code=en&fmt=json&tab=${tab}"
    local data
    
    log_message "Downloading data from ${url}..."
    
    # Fetch data with timeout and retry
    for i in {1..3}; do
        data=$(curl -s --max-time 10 "$url")
        if [ $? -eq 0 ] && [ -n "$data" ]; then
            break
        fi
        if [ $i -eq 3 ]; then
            log_error "Failed to fetch data after 3 attempts from ${url}"
            return 1
        fi
        sleep 2
    done
    
    # Validate JSON
    if ! echo "$data" | jq -e . >/dev/null 2>&1; then
        log_error "Invalid JSON data received from ${url}"
        return 1
    fi
        
    echo "$data"
    return 0
}

# Function to fetch game information from the WHL scores page for a specific date
get_game_info_for_date() {
    local target_date=$1
    
    echo "Checking for games on ${target_date}..." >&2
    
    # Use the WHL scores page to get games for the date
    local scores_url="https://chl.ca/whl/scores/${target_date}/"
    
    echo "Fetching scores from ${scores_url}..." >&2
    
    # Fetch scores data
    local scores_data
    scores_data=$(curl -s --max-time 10 "$scores_url")
    
    if [ $? -ne 0 ] || [ -z "$scores_data" ]; then
        log_error "Failed to fetch scores data for ${target_date}"
        return 1
    fi
    
    # Extract the JSON data from the HTML response
    local json_data
    json_data=$(echo "$scores_data" | grep -o '{"client_code":"whl".*}' | head -1)
    
    if [ -z "$json_data" ]; then
        log_error "Failed to extract JSON data from scores page"
        return 1
    fi
    
    # Find games involving Seattle Thunderbirds (team_id 214, code SEA)
    local sea_game
    sea_game=$(echo "$json_data" | jq -r '.scores[] | select(.home_team_code == "SEA" or .visiting_team_code == "SEA") | select(.playoff == "1")')
    
    if [ -z "$sea_game" ]; then
        log_error "No playoff games found for Seattle Thunderbirds on ${target_date}"
        return 1
    fi
    
    # Extract game details
    local game_id=$(echo "$sea_game" | jq -r '.id')
    local home_team=$(echo "$sea_game" | jq -r '.home_team_code')
    local visiting_team=$(echo "$sea_game" | jq -r '.visiting_team_code')
    local home_score=$(echo "$sea_game" | jq -r '.home_goal_count')
    local visiting_score=$(echo "$sea_game" | jq -r '.visiting_goal_count')
    
    if [ -z "$game_id" ] || [ -z "$home_team" ] || [ -z "$visiting_team" ]; then
        log_error "Failed to extract game details"
        return 1
    fi
    
    echo "Found playoff game: ${visiting_team} (${visiting_score}) @ ${home_team} (${home_score}) (Game ID: ${game_id})" >&2
    
    # Return all info in a format we can parse later
    echo "${game_id}:${home_team}:${visiting_team}:${home_score}:${visiting_score}"
    return 0
}

# Function to download and save WHL game data
download_whl_game() {
    local date=$1
    local game_id=$2
    local home_team=$3
    local visiting_team=$4
    local home_score=$5
    local visiting_score=$6
    
    # Format date for filename
    local file_date=${date//-/}
    
    # Create playoffs directory if it doesn't exist
    mkdir -p "$PLAYOFFS_DIR"

    # Save game summary
    local summary_data
    summary_data=$(fetch_whl_data "$game_id" "gamesummary")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch game summary"
        return 1
    fi
    
    local summary_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-gamesummary.json"
    local summary_filepath="${PLAYOFFS_DIR}/${summary_filename}"
    log_message "Saving game summary to ${summary_filepath}..."
    if ! echo "$summary_data" | python3 -m json.tool > "$summary_filepath"; then
        log_error "Failed to save game summary"
        return 1
    fi

    # Save play-by-play
    local pxp_data
    pxp_data=$(fetch_whl_data "$game_id" "pxpverbose")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch play-by-play data"
        return 1
    fi
    
    local pxp_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-pxpverbose.json"
    local pxp_filepath="${PLAYOFFS_DIR}/${pxp_filename}"
    log_message "Saving play-by-play to ${pxp_filepath}..."
    if ! echo "$pxp_data" | python3 -m json.tool > "$pxp_filepath"; then
        log_error "Failed to save play-by-play data"
        return 1
    fi

    # Determine winner
    local result
    if [ "$home_team" = "SEA" ]; then
        if [ "$home_score" -gt "$visiting_score" ]; then
            result="Seattle wins ${home_score}-${visiting_score}"
        else
            result="Seattle loses ${visiting_score}-${home_score}"
        fi
    else
        if [ "$visiting_score" -gt "$home_score" ]; then
            result="Seattle wins ${visiting_score}-${home_score}"
        else
            result="Seattle loses ${home_score}-${visiting_score}"
        fi
    fi

    log_message "Download complete!"
    log_message "Game result: $result"
    log_message "To update the README.md, add the following line:"
    log_message "- [ROUND 1 GAME #4: ${date} ${result} against Everett Silvertips](./2024-25/playoffs/${pxp_filename})"
    
    return 0
}

# Main execution
main() {
    # Get date from command line or use today's date
    local today=$(date '+%Y-%m-%d')
    local date=${1:-$today}
    
    # Validate date format
    if ! validate_date "$date"; then
        usage
    fi
    
    # Get game info for the date
    local game_info
    game_info=$(get_game_info_for_date "$date")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # Parse game info
    local game_id=$(echo "$game_info" | cut -d':' -f1)
    local home_team=$(echo "$game_info" | cut -d':' -f2)
    local visiting_team=$(echo "$game_info" | cut -d':' -f3)
    local home_score=$(echo "$game_info" | cut -d':' -f4)
    local visiting_score=$(echo "$game_info" | cut -d':' -f5)
    
    log_message "Found playoff game for ${date}: ${visiting_team} (${visiting_score}) vs ${home_team} (${home_score}) (Game ID: ${game_id})"
    
    # Download game data
    download_whl_game "$date" "$game_id" "$home_team" "$visiting_team" "$home_score" "$visiting_score"
}

# Execute main function with all arguments
main "$@"
