#!/bin/bash

# NHL Scores Fetcher - Grab NHL game data and copy to clipboard
# Usage:
#   ./src/get_nhl_scores.sh              # Get today's scores
#   ./src/get_nhl_scores.sh 2025-11-19   # Get scores for specific date
#   ./src/get_nhl_scores.sh --help       # Show help

set -euo pipefail

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# API endpoint
readonly API_URL="https://sploosh-ai-hockey-analytics.vercel.app/api/nhl/scores"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${RESET}"
}

# Function to print section headers
print_header() {
    echo ""
    print_color "${BOLD}${CYAN}" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "${BOLD}${CYAN}" "  $*"
    print_color "${BOLD}${CYAN}" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to show usage
usage() {
    cat << EOF
${BOLD}NHL Schedule Fetcher${RESET} 🏒

Fetch NHL game schedules and results, copy them to your clipboard.

${BOLD}USAGE:${RESET}
    $0 [DATE] [OPTIONS]

${BOLD}ARGUMENTS:${RESET}
    DATE        Optional date in YYYY-MM-DD format (defaults to today)

${BOLD}OPTIONS:${RESET}
    --no-copy   Display results without copying to clipboard
    --raw       Show raw JSON without pretty formatting
    --help      Show this help message

${BOLD}EXAMPLES:${RESET}
    $0                      # Get today's scores
    $0 2025-11-19          # Get scores for November 19th, 2025
    $0 --no-copy           # Display today's scores without copying
    $0 2025-11-19 --raw    # Get raw JSON for specific date

EOF
    exit 0
}

# Function to validate date format
validate_date() {
    local date=$1
    if ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        print_color "${RED}" "❌ Error: Invalid date format. Use YYYY-MM-DD"
        exit 1
    fi
}

# Function to format game status with period/time info
format_game_status() {
    local status=$1
    local period=$2
    local period_type=$3
    local time_remaining=$4
    local in_intermission=$5
    
    case "$status" in
        "FINAL"|"OFF")
            if [ "$period_type" = "OT" ]; then
                echo "🏁 Final/OT"
            elif [ "$period_type" = "SO" ]; then
                echo "🏁 Final/SO"
            else
                echo "🏁 Final"
            fi
            ;;
        "LIVE"|"CRIT")
            if [ "$in_intermission" = "true" ]; then
                # Intermission - use pause icon with proper spacing
                local ordinal_suffix=""
                case "$period" in
                    1) ordinal_suffix="st" ;;
                    2) ordinal_suffix="nd" ;;
                    3) ordinal_suffix="rd" ;;
                    *) ordinal_suffix="th" ;;
                esac
                echo "⏸️  ${period}${ordinal_suffix} INT|${time_remaining}"
            else
                local period_display=""
                local icon=""
                case "$period_type" in
                    "REG")
                        # Active play - use play icon with proper spacing
                        icon="▶️  "
                        local ordinal_suffix=""
                        case "$period" in
                            1) ordinal_suffix="st" ;;
                            2) ordinal_suffix="nd" ;;
                            3) ordinal_suffix="rd" ;;
                            *) ordinal_suffix="th" ;;
                        esac
                        period_display="${period}${ordinal_suffix}"
                        ;;
                    "OT")
                        # Overtime - use fire icon for intensity
                        icon="🔥 "
                        period_display="OT   "
                        ;;
                    "SO")
                        # Shootout - use target icon
                        icon="🎯 "
                        period_display="SO   "
                        ;;
                    *)
                        icon="▶️  "
                        period_display="P${period}"
                        ;;
                esac
                echo "${icon}${period_display}|${time_remaining}"
            fi
            ;;
        "FUT"|"PRE")
            echo "⏰ Scheduled"
            ;;
        *)
            echo "📊 $status"
            ;;
    esac
}

# Function to display pretty game summary
display_game_summary() {
    local json_data=$1
    local game_count=$(echo "$json_data" | jq -r '.games | length')
    
    if [ "$game_count" -eq 0 ]; then
        print_color "${YELLOW}" "📭 No games found for this date"
        return
    fi
    
    print_color "${GREEN}" "🏒 Found ${BOLD}${game_count}${RESET}${GREEN} game(s)"
    echo ""
    
    # Display legend for visual indicators
    print_color "${CYAN}" "Legend: ▶️  Active  ⏸️  Intermission  🔥 Overtime  🎯 Shootout  🏁 Final  ⏰ Scheduled"
    echo ""
    
    # Parse and display each game with period/clock info
    echo "$json_data" | jq -r '.games[] | 
        "\(.awayTeam.abbrev)|\(.awayTeam.score // "0")|\(.homeTeam.abbrev)|\(.homeTeam.score // "0")|\(.gameState)|\(.startTimeUTC)|\(.period // 0)|\(.periodDescriptor.periodType // "")|\(.clock.timeRemaining // "")|\(.clock.inIntermission // false)"' | 
    while IFS='|' read -r away_team away_score home_team home_score status start_time period period_type time_remaining in_intermission; do
        local status_full=$(format_game_status "$status" "$period" "$period_type" "$time_remaining" "$in_intermission")
        local matchup_display="${BOLD}${away_team}${RESET} @ ${BOLD}${home_team}${RESET}"
        
        # Create matchup without formatting for alignment calculation
        local matchup_plain="${away_team} @ ${home_team}"
        
        if [ "$status" = "FUT" ] || [ "$status" = "PRE" ]; then
            # Scheduled games: show status icon, empty time column, matchup, then time
            # Format time for scheduled games - convert from UTC to local time
            local epoch_time=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$start_time" "+%s" 2>/dev/null)
            if [ -n "$epoch_time" ]; then
                local game_time=$(date -r "$epoch_time" "+%I:%M %p %Z" 2>/dev/null)
                # Format: status (14 chars), empty time column (10 chars), matchup (13 chars), game time (aligned with score)
                printf "  %-14s%-10s%-13s%b\n" "${status_full}" "" "${matchup_plain}" "${CYAN}${game_time}${RESET}"
            else
                printf "  %-14s%-10s%-13s%b\n" "${status_full}" "" "${matchup_plain}" "${CYAN}${start_time}${RESET}"
            fi
        else
            # Live/completed games: split status into period and time columns
            if [[ "$status_full" == *"|"* ]]; then
                # Active/intermission game with time - split into period and time
                local status_period="${status_full%|*}"
                local status_time="${status_full#*|}"
                local score_display="${BOLD}${away_score} - ${home_score}${RESET}"
                # Format: period (18 chars), time (10 chars), matchup (13 chars), score (7 chars)
                printf "  %-18s%-10s%-13s%b\n" "${status_period}" "${status_time}" "${matchup_plain}" "${score_display}"
            else
                # Completed game without time
                local score_display="${BOLD}${away_score} - ${home_score}${RESET}"
                printf "  %-25s%-13s%b\n" "${status_full}" "${matchup_plain}" "${score_display}"
            fi
        fi
    done
}

# Function to copy to clipboard
copy_to_clipboard() {
    local data=$1
    
    if command -v pbcopy &> /dev/null; then
        echo "$data" | pbcopy
        return 0
    elif command -v xclip &> /dev/null; then
        echo "$data" | xclip -selection clipboard
        return 0
    elif command -v xsel &> /dev/null; then
        echo "$data" | xsel --clipboard --input
        return 0
    else
        print_color "${RED}" "❌ Error: No clipboard utility found (pbcopy, xclip, or xsel)"
        return 1
    fi
}

# Main function
main() {
    local date=""
    local no_copy=false
    local raw_output=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                ;;
            --no-copy)
                no_copy=true
                shift
                ;;
            --raw)
                raw_output=true
                shift
                ;;
            -*)
                print_color "${RED}" "❌ Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
            *)
                if [ -z "$date" ]; then
                    date=$1
                    validate_date "$date"
                else
                    print_color "${RED}" "❌ Error: Multiple dates specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Default to today if no date specified
    if [ -z "$date" ]; then
        date=$(date +%Y-%m-%d)
    fi
    
    # Display header
    print_header "🏒 NHL Scores - $date"
    
    # Fetch data
    print_color "${BLUE}" "📡 Fetching data from API..."
    local json_data
    if ! json_data=$(curl -sf "${API_URL}?date=${date}"); then
        print_color "${RED}" "❌ Error: Failed to fetch data from API"
        print_color "${YELLOW}" "   URL: ${API_URL}?date=${date}"
        exit 1
    fi
    
    # Validate JSON
    if ! echo "$json_data" | jq -e . >/dev/null 2>&1; then
        print_color "${RED}" "❌ Error: Invalid JSON response from API"
        exit 1
    fi
    
    # Display game summary (unless raw output requested)
    if [ "$raw_output" = false ]; then
        echo ""
        display_game_summary "$json_data"
    fi
    
    # Copy to clipboard
    if [ "$no_copy" = false ]; then
        echo ""
        if copy_to_clipboard "$json_data"; then
            print_color "${GREEN}" "✅ Data copied to clipboard!"
            print_color "${CYAN}" "   Ready to paste anywhere"
        else
            print_color "${YELLOW}" "⚠️  Could not copy to clipboard, but here's the data:"
            echo ""
            if [ "$raw_output" = true ]; then
                echo "$json_data"
            else
                echo "$json_data" | jq '.'
            fi
        fi
    else
        echo ""
        print_color "${BLUE}" "📋 Output (not copied to clipboard):"
        echo ""
        if [ "$raw_output" = true ]; then
            echo "$json_data"
        else
            echo "$json_data" | jq '.'
        fi
    fi
    
    # Footer
    echo ""
    print_color "${MAGENTA}" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "${GREEN}" "✨ Done!"
    echo ""
}

# Run main function
main "$@"
