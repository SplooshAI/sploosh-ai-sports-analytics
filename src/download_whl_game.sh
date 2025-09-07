#!/bin/bash

# Download WHL game data for Seattle Thunderbirds
# This script downloads WHL game data (regular season, preseason, or playoff) for a specified date
# 
# Usage: 
#   ./download_whl_game.sh [date] [game_type]
#   ./download_whl_game.sh 2025-09-05 preseason
#   ./download_whl_game.sh 2025-01-15 regular
#   ./download_whl_game.sh 2025-04-10 playoff
#
# If no date is provided, today's date will be used
# If no game type is provided, the script will attempt to detect it automatically

# Constants
readonly API_KEY="41b145a848f4bd67"
readonly DATA_BASE_DIR="data/WHL - Western Hockey League"
readonly THUNDERBIRDS_TEAM_ID=214  # Seattle Thunderbirds team ID
readonly THUNDERBIRDS_CODE="SEA"   # Seattle Thunderbirds team code

# Function to print usage instructions
usage() {
    echo "Usage: $0 [date] [game_type]"
    echo "  date: Optional date in YYYY-MM-DD format (defaults to today)"
    echo "  game_type: Optional game type (preseason, regular, playoff)"
    echo "             If not provided, the script will attempt to detect it automatically"
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

# Function to determine season based on date
determine_season() {
    local date=$1
    local year=${date:0:4}
    local month=${date:5:2}
    
    # WHL season typically runs from September to April
    # If month is between September and December, season is YEAR-YY
    # If month is between January and August, season is YEAR-1-YY
    if [ "$month" -ge 9 ] && [ "$month" -le 12 ]; then
        local next_year=$((year + 1))
        local next_year_short=${next_year: -2}
        echo "${year}-${next_year_short}"
    else
        local prev_year=$((year - 1))
        local year_short=${year: -2}
        echo "${prev_year}-${year_short}"
    fi
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
    local game_type=$2
    
    log_message "Checking for games on ${target_date}..."
    
    # Use the WHL scores page to get games for the date
    local scores_url="https://chl.ca/whl/scores/${target_date}/"
    
    log_message "Fetching scores from ${scores_url}..."
    
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
    
    # Find games involving Seattle Thunderbirds (code SEA)
    local sea_game
    
    if [ "$game_type" = "preseason" ]; then
        sea_game=$(echo "$json_data" | jq -r '.scores[] | select(.home_team_code == "SEA" or .visiting_team_code == "SEA") | select(.preseason == "1")')
        if [ -z "$sea_game" ]; then
            log_error "No preseason games found for Seattle Thunderbirds on ${target_date}"
            return 1
        fi
    elif [ "$game_type" = "playoff" ]; then
        sea_game=$(echo "$json_data" | jq -r '.scores[] | select(.home_team_code == "SEA" or .visiting_team_code == "SEA") | select(.playoff == "1")')
        if [ -z "$sea_game" ]; then
            log_error "No playoff games found for Seattle Thunderbirds on ${target_date}"
            return 1
        fi
    elif [ "$game_type" = "regular" ]; then
        sea_game=$(echo "$json_data" | jq -r '.scores[] | select(.home_team_code == "SEA" or .visiting_team_code == "SEA") | select(.preseason != "1" and .playoff != "1")')
        if [ -z "$sea_game" ]; then
            log_error "No regular season games found for Seattle Thunderbirds on ${target_date}"
            return 1
        fi
    else
        # Auto-detect game type
        sea_game=$(echo "$json_data" | jq -r '.scores[] | select(.home_team_code == "SEA" or .visiting_team_code == "SEA")')
        if [ -z "$sea_game" ]; then
            log_error "No games found for Seattle Thunderbirds on ${target_date}"
            return 1
        fi
        
        # Determine game type
        local is_preseason=$(echo "$sea_game" | jq -r '.preseason')
        local is_playoff=$(echo "$sea_game" | jq -r '.playoff')
        
        if [ "$is_preseason" = "1" ]; then
            game_type="preseason"
        elif [ "$is_playoff" = "1" ]; then
            game_type="playoff"
        else
            game_type="regular"
        fi
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
    
    log_message "Found ${game_type} game: ${visiting_team} (${visiting_score}) @ ${home_team} (${home_score}) (Game ID: ${game_id})"
    
    # Return all info in a format we can parse later
    echo "${game_id}:${home_team}:${visiting_team}:${home_score}:${visiting_score}:${game_type}"
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
    local game_type=$7
    
    # Format date for filename
    local file_date=${date//-/}
    
    # Determine season based on date
    local season=$(determine_season "$date")
    
    # Set output directory based on game type
    local output_dir
    if [ "$game_type" = "preseason" ]; then
        output_dir="${DATA_BASE_DIR}/${season}/preseason"
    elif [ "$game_type" = "playoff" ]; then
        output_dir="${DATA_BASE_DIR}/${season}/playoffs"
    else
        output_dir="${DATA_BASE_DIR}/${season}"
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Save game summary
    local summary_data
    summary_data=$(fetch_whl_data "$game_id" "gamesummary")
    if [ $? -ne 0 ]; then
        log_error "Failed to fetch game summary"
        return 1
    fi
    
    # Construct filename based on game type
    local summary_filename
    if [ "$game_type" = "preseason" ]; then
        summary_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-preseason-gamesummary.json"
    elif [ "$game_type" = "playoff" ]; then
        summary_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-playoff-gamesummary.json"
    else
        summary_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-gamesummary.json"
    fi
    
    local summary_filepath="${output_dir}/${summary_filename}"
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
    
    # Construct filename based on game type
    local pxp_filename
    if [ "$game_type" = "preseason" ]; then
        pxp_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-preseason-pxpverbose.json"
    elif [ "$game_type" = "playoff" ]; then
        pxp_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-playoff-pxpverbose.json"
    else
        pxp_filename="${file_date}-${visiting_team}-vs-${home_team}-${game_id}-pxpverbose.json"
    fi
    
    local pxp_filepath="${output_dir}/${pxp_filename}"
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
    
    # Get opponent name
    local opponent
    if [ "$home_team" = "SEA" ]; then
        opponent="$visiting_team"
    else
        opponent="$home_team"
    fi
    
    log_message "Download complete!"
    log_message "Game result: $result"
    log_message "To update the README.md, add the following line:"
    
    if [ "$game_type" = "preseason" ]; then
        log_message "- [PRESEASON GAME: ${date} ${result} against ${opponent}](${season}/preseason/${pxp_filename})"
    elif [ "$game_type" = "playoff" ]; then
        log_message "- [PLAYOFF GAME: ${date} ${result} against ${opponent}](${season}/playoffs/${pxp_filename})"
    else
        log_message "- [REGULAR SEASON GAME: ${date} ${result} against ${opponent}](${season}/${pxp_filename})"
    fi
    
    return 0
}

# Function to download multiple games by date
download_multiple_games() {
    local dates=("$@")
    local success_count=0
    local fail_count=0
    
    for date in "${dates[@]}"; do
        if ! validate_date "$date"; then
            log_error "Invalid date format: $date"
            ((fail_count++))
            continue
        fi
        
        log_message "Processing game for date: $date"
        
        # Try to find a game for this date (auto-detect game type)
        local game_info
        game_info=$(get_game_info_for_date "$date" "")
        if [ $? -ne 0 ]; then
            log_error "Failed to get game info for date: $date"
            ((fail_count++))
            continue
        fi
        
        # Parse game info
        local game_id=$(echo "$game_info" | cut -d':' -f1)
        local home_team=$(echo "$game_info" | cut -d':' -f2)
        local visiting_team=$(echo "$game_info" | cut -d':' -f3)
        local home_score=$(echo "$game_info" | cut -d':' -f4)
        local visiting_score=$(echo "$game_info" | cut -d':' -f5)
        local game_type=$(echo "$game_info" | cut -d':' -f6)
        
        log_message "Found ${game_type} game for ${date}: ${visiting_team} (${visiting_score}) vs ${home_team} (${home_score}) (Game ID: ${game_id})"
        
        # Download game data
        if download_whl_game "$date" "$game_id" "$home_team" "$visiting_team" "$home_score" "$visiting_score" "$game_type"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done
    
    log_message "Download summary: ${success_count} games downloaded successfully, ${fail_count} failed"
    
    if [ $success_count -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Main execution
main() {
    # Check if multiple dates are provided
    if [ $# -gt 1 ]; then
        # Check if the second argument is a game type
        if [[ "$2" =~ ^(preseason|regular|playoff)$ ]]; then
            # Single date with game type specified
            local date=$1
            local game_type=$2
            
            # Validate date format
            if ! validate_date "$date"; then
                usage
            fi
            
            # Get game info for the date
            local game_info
            game_info=$(get_game_info_for_date "$date" "$game_type")
            if [ $? -ne 0 ]; then
                exit 1
            fi
            
            # Parse game info
            local game_id=$(echo "$game_info" | cut -d':' -f1)
            local home_team=$(echo "$game_info" | cut -d':' -f2)
            local visiting_team=$(echo "$game_info" | cut -d':' -f3)
            local home_score=$(echo "$game_info" | cut -d':' -f4)
            local visiting_score=$(echo "$game_info" | cut -d':' -f5)
            local detected_game_type=$(echo "$game_info" | cut -d':' -f6)
            
            # Download game data
            download_whl_game "$date" "$game_id" "$home_team" "$visiting_team" "$home_score" "$visiting_score" "$game_type"
        else
            # Multiple dates provided
            download_multiple_games "$@"
        fi
    else
        # Get date from command line or use today's date
        local today=$(date '+%Y-%m-%d')
        local date=${1:-$today}
        
        # Validate date format
        if ! validate_date "$date"; then
            usage
        fi
        
        # Get game info for the date (auto-detect game type)
        local game_info
        game_info=$(get_game_info_for_date "$date" "")
        if [ $? -ne 0 ]; then
            exit 1
        fi
        
        # Parse game info
        local game_id=$(echo "$game_info" | cut -d':' -f1)
        local home_team=$(echo "$game_info" | cut -d':' -f2)
        local visiting_team=$(echo "$game_info" | cut -d':' -f3)
        local home_score=$(echo "$game_info" | cut -d':' -f4)
        local visiting_score=$(echo "$game_info" | cut -d':' -f5)
        local game_type=$(echo "$game_info" | cut -d':' -f6)
        
        log_message "Found ${game_type} game for ${date}: ${visiting_team} (${visiting_score}) vs ${home_team} (${home_score}) (Game ID: ${game_id})"
        
        # Download game data
        download_whl_game "$date" "$game_id" "$home_team" "$visiting_team" "$home_score" "$visiting_score" "$game_type"
    fi
}

# Execute main function with all arguments
main "$@"
