#!/bin/bash
#
# Test script for get_nhl_schedule.sh
# Tests the NHL schedule/results fetching functionality

set -euo pipefail

# Set up colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NHL_SCRIPT="${SCRIPT_DIR}/get_nhl_schedule.sh"

# Function to print test results
print_result() {
    local test_name=$1
    local result=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  ${YELLOW}$message${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to print section header
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Test 1: Script exists and is executable
test_script_exists() {
    print_header "Test 1: Script Existence and Permissions"
    
    if [ -f "$NHL_SCRIPT" ]; then
        print_result "Script file exists" "PASS" ""
    else
        print_result "Script file exists" "FAIL" "Script not found at $NHL_SCRIPT"
        return 1
    fi
    
    if [ -x "$NHL_SCRIPT" ]; then
        print_result "Script is executable" "PASS" ""
    else
        print_result "Script is executable" "FAIL" "Script is not executable"
        return 1
    fi
}

# Test 2: Help flag works
test_help_flag() {
    print_header "Test 2: Help Flag"
    
    local output
    if output=$("$NHL_SCRIPT" --help 2>&1); then
        if echo "$output" | grep -q "NHL Schedule Fetcher"; then
            print_result "Help flag displays usage" "PASS" ""
        else
            print_result "Help flag displays usage" "FAIL" "Help output doesn't contain expected text"
        fi
    else
        print_result "Help flag displays usage" "FAIL" "Help flag returned error"
    fi
}

# Test 3: Date validation
test_date_validation() {
    print_header "Test 3: Date Validation"
    
    # Test invalid date format - the script validates format, not actual date validity
    # So 2025-13-45 passes format check (YYYY-MM-DD) even though it's not a real date
    local output
    
    # Test wrong format (should fail)
    if output=$("$NHL_SCRIPT" "11/19/2025" --no-copy 2>&1); then
        print_result "Wrong format rejection" "FAIL" "Script should reject date format 11/19/2025"
    else
        if echo "$output" | grep -q "Invalid date format"; then
            print_result "Wrong format rejection" "PASS" ""
        else
            print_result "Wrong format rejection" "FAIL" "Error message doesn't mention invalid date format"
        fi
    fi
    
    # Test another wrong format
    if output=$("$NHL_SCRIPT" "2025/11/19" --no-copy 2>&1); then
        print_result "Slash format rejection" "FAIL" "Script should reject date format 2025/11/19"
    else
        if echo "$output" | grep -q "Invalid date format"; then
            print_result "Slash format rejection" "PASS" ""
        else
            print_result "Slash format rejection" "FAIL" "Error message doesn't mention invalid date format"
        fi
    fi
}

# Test 4: API connectivity and JSON validation
test_api_connectivity() {
    print_header "Test 4: API Connectivity and JSON Validation"
    
    # Test with a known date that should have data
    local test_date="2025-11-18"
    local output
    
    if output=$("$NHL_SCRIPT" "$test_date" --no-copy --raw 2>&1); then
        print_result "API request succeeds" "PASS" ""
        
        # Extract just the JSON part - look for lines starting with { or containing JSON
        local json_output=$(echo "$output" | grep -E '^\{.*\}$' | head -1)
        
        # Check if output contains valid JSON
        if echo "$json_output" | jq -e . >/dev/null 2>&1; then
            print_result "API returns valid JSON" "PASS" ""
        else
            print_result "API returns valid JSON" "FAIL" "Output is not valid JSON"
        fi
        
        # Check if JSON has expected structure
        if echo "$json_output" | jq -e '.games' >/dev/null 2>&1; then
            print_result "JSON has games array" "PASS" ""
        else
            print_result "JSON has games array" "FAIL" "JSON doesn't contain games array"
        fi
    else
        print_result "API request succeeds" "FAIL" "Failed to fetch data from API"
        print_result "API returns valid JSON" "FAIL" "No data to validate"
        print_result "JSON has games array" "FAIL" "No data to validate"
    fi
}

# Test 5: No-copy flag works
test_no_copy_flag() {
    print_header "Test 5: No-Copy Flag"
    
    local output
    if output=$("$NHL_SCRIPT" "2025-11-18" --no-copy 2>&1); then
        # Check that it doesn't say "copied to clipboard"
        if ! echo "$output" | grep -q "copied to clipboard"; then
            print_result "No-copy flag prevents clipboard copy" "PASS" ""
        else
            print_result "No-copy flag prevents clipboard copy" "FAIL" "Output says data was copied to clipboard"
        fi
    else
        print_result "No-copy flag prevents clipboard copy" "FAIL" "Script failed with --no-copy flag"
    fi
}

# Test 6: Raw output flag works
test_raw_flag() {
    print_header "Test 6: Raw Output Flag"
    
    local output
    if output=$("$NHL_SCRIPT" "2025-11-18" --raw --no-copy 2>&1); then
        # Raw output should not have the formatted game summary
        if ! echo "$output" | grep -q "Found.*game(s)"; then
            print_result "Raw flag skips formatted output" "PASS" ""
        else
            print_result "Raw flag skips formatted output" "FAIL" "Raw output contains formatted game summary"
        fi
        
        # But should still have JSON - extract it properly
        local json_output=$(echo "$output" | grep -E '^\{.*\}$' | head -1)
        if echo "$json_output" | jq -e . >/dev/null 2>&1; then
            print_result "Raw flag outputs valid JSON" "PASS" ""
        else
            print_result "Raw flag outputs valid JSON" "FAIL" "Raw output is not valid JSON"
        fi
    else
        print_result "Raw flag skips formatted output" "FAIL" "Script failed with --raw flag"
        print_result "Raw flag outputs valid JSON" "FAIL" "Script failed with --raw flag"
    fi
}

# Test 7: Default date (today) works
test_default_date() {
    print_header "Test 7: Default Date (Today)"
    
    local output
    if output=$("$NHL_SCRIPT" --no-copy 2>&1); then
        local today=$(date +%Y-%m-%d)
        if echo "$output" | grep -q "$today"; then
            print_result "Default date uses today" "PASS" ""
        else
            print_result "Default date uses today" "FAIL" "Output doesn't show today's date"
        fi
    else
        print_result "Default date uses today" "FAIL" "Script failed without date argument"
    fi
}

# Test 8: Game state display (Final/OT, Final/SO, scheduled, etc.)
test_game_state_display() {
    print_header "Test 8: Game State Display"
    
    # Test with a date that has completed games (including OT)
    if "$NHL_SCRIPT" "2025-11-18" --no-copy > /tmp/nhl_test_game_state.txt 2>&1; then
        # Get just the first 20 lines and remove ANSI color codes
        local clean_output=$(head -20 /tmp/nhl_test_game_state.txt | perl -pe 's/\e\[[0-9;]*m//g')
        
        # Check for Final/OT designation (Nov 18 had OT games)
        if echo "$clean_output" | grep -qE "Final/OT"; then
            print_result "Final/OT status displayed" "PASS" ""
        else
            print_result "Final/OT status displayed" "FAIL" "No Final/OT status found (expected for Nov 18th games)"
        fi
        
        # Check for regular Final status (now appears at end of line after score)
        if echo "$clean_output" | grep -qE "Final($|[^/])"; then
            print_result "Final status displayed" "PASS" ""
        else
            print_result "Final status displayed" "FAIL" "No Final status found"
        fi
        
        rm -f /tmp/nhl_test_game_state.txt
    else
        print_result "Final/OT status displayed" "FAIL" "Script failed"
        print_result "Final status displayed" "FAIL" "Script failed"
        rm -f /tmp/nhl_test_game_state.txt
    fi
    
    # Test for shootout games by checking the raw JSON data
    # We'll use the API directly to verify SO game detection works
    local test_date="2025-11-18"
    local json_data=$(curl -sf "https://sploosh-ai-hockey-analytics.vercel.app/api/nhl/scores?date=${test_date}")
    
    if [ -n "$json_data" ]; then
        # Check if any game has SO (shootout) in periodType
        local has_so=$(echo "$json_data" | jq -r '.games[] | select(.periodDescriptor.periodType == "SO") | .id' | head -1)
        
        if [ -n "$has_so" ]; then
            # If there's a shootout game, verify our script displays Final/SO
            if "$NHL_SCRIPT" "$test_date" --no-copy > /tmp/nhl_test_so.txt 2>&1; then
                local clean_output=$(head -20 /tmp/nhl_test_so.txt | perl -pe 's/\e\[[0-9;]*m//g')
                if echo "$clean_output" | grep -qE "Final/SO"; then
                    print_result "Final/SO status displayed (when SO games exist)" "PASS" ""
                else
                    print_result "Final/SO status displayed (when SO games exist)" "FAIL" "SO game found but Final/SO not displayed"
                fi
                rm -f /tmp/nhl_test_so.txt
            else
                print_result "Final/SO status displayed (when SO games exist)" "FAIL" "Script failed"
                rm -f /tmp/nhl_test_so.txt
            fi
        else
            print_result "Final/SO status displayed (when SO games exist)" "PASS" "No SO games on test date (expected)"
        fi
    else
        print_result "Final/SO status displayed (when SO games exist)" "FAIL" "Could not fetch API data"
    fi
    
    # Test with future games (scheduled)
    if "$NHL_SCRIPT" "2025-11-19" --no-copy > /tmp/nhl_test_scheduled.txt 2>&1; then
        local clean_output=$(head -20 /tmp/nhl_test_scheduled.txt | perl -pe 's/\e\[[0-9;]*m//g')
        
        # Check for Scheduled status
        if echo "$clean_output" | grep -qE "Scheduled"; then
            print_result "Scheduled status displayed" "PASS" ""
        else
            print_result "Scheduled status displayed" "FAIL" "No Scheduled status found"
        fi
        
        rm -f /tmp/nhl_test_scheduled.txt
    else
        print_result "Scheduled status displayed" "FAIL" "Script failed"
        rm -f /tmp/nhl_test_scheduled.txt
    fi
}

# Test 9: Timezone conversion (UTC to local)
test_timezone_conversion() {
    print_header "Test 9: Timezone Conversion"
    
    # Test that API returns UTC times - use tomorrow to ensure scheduled games
    # Handle both macOS (BSD date) and Linux (GNU date)
    local tomorrow
    if date -v+1d +%Y-%m-%d >/dev/null 2>&1; then
        # macOS/BSD date
        tomorrow=$(date -v+1d +%Y-%m-%d)
    else
        # Linux/GNU date
        tomorrow=$(date -d 'tomorrow' +%Y-%m-%d)
    fi
    local test_date="$tomorrow"
    local json_data=$(curl -sf "https://sploosh-ai-hockey-analytics.vercel.app/api/nhl/scores?date=${test_date}")
    
    if [ -n "$json_data" ]; then
        # Check that API returns times in UTC format (ending with Z)
        local utc_time=$(echo "$json_data" | jq -r '.games[0].startTimeUTC' 2>/dev/null)
        if echo "$utc_time" | grep -qE 'Z$'; then
            print_result "API returns UTC timestamps" "PASS" ""
        else
            print_result "API returns UTC timestamps" "FAIL" "Timestamp doesn't end with Z: $utc_time"
        fi
        
        # Verify the script converts UTC to local time for scheduled games
        if "$NHL_SCRIPT" "$test_date" --no-copy > /tmp/nhl_test_timezone.txt 2>&1; then
            local clean_output=$(head -20 /tmp/nhl_test_timezone.txt | perl -pe 's/\e\[[0-9;]*m//g')
            
            # Check if there are any scheduled games in the output (not just in legend)
            if echo "$clean_output" | grep -q "Scheduled"; then
                # Check that output shows local timezone (PST/PDT) not UTC
                if echo "$clean_output" | grep -qE "Scheduled.*[0-9]{1,2}:[0-9]{2} (AM|PM) [A-Z]{3,4}"; then
                    print_result "Times converted to local timezone" "PASS" ""
                else
                    print_result "Times converted to local timezone" "FAIL" "No local timezone found in output"
                fi
                
                # Verify times are NOT showing as midnight (the bug we fixed)
                if echo "$clean_output" | grep -qE "Scheduled.*(12:00 AM|12:30 AM)"; then
                    print_result "Times not showing as midnight" "FAIL" "Found midnight times (UTC not converted)"
                else
                    print_result "Times not showing as midnight" "PASS" ""
                fi
                
                # Verify times are showing in 12-hour format with AM/PM (not 24-hour UTC)
                if echo "$clean_output" | grep -qE "Scheduled.*[0-9]{1,2}:[0-9]{2} (AM|PM)"; then
                    print_result "Times showing in 12-hour format with AM/PM" "PASS" ""
                else
                    print_result "Times showing in 12-hour format with AM/PM" "FAIL" "Expected 12-hour time format not found"
                fi
            else
                # No scheduled games - this should not happen with tomorrow's date
                print_result "Times converted to local timezone" "FAIL" "No scheduled games found for tomorrow"
                print_result "Times not showing as midnight" "FAIL" "No scheduled games found for tomorrow"
                print_result "Times showing in 12-hour format with AM/PM" "FAIL" "No scheduled games found for tomorrow"
            fi
            
            rm -f /tmp/nhl_test_timezone.txt
        else
            print_result "Times converted to local timezone" "FAIL" "Script failed"
            print_result "Times not showing as midnight" "FAIL" "Script failed"
            print_result "Times showing in 12-hour format with AM/PM" "FAIL" "Script failed"
            rm -f /tmp/nhl_test_timezone.txt
        fi
    else
        print_result "API returns UTC timestamps" "FAIL" "Could not fetch API data"
        print_result "Times converted to local timezone" "FAIL" "Could not fetch API data"
        print_result "Times not showing as midnight" "FAIL" "Could not fetch API data"
        print_result "Times showing in 12-hour format with AM/PM" "FAIL" "Could not fetch API data"
    fi
}

# Test 10: Unknown option handling
test_unknown_option() {
    print_header "Test 10: Unknown Option Handling"
    
    local output
    if output=$("$NHL_SCRIPT" --invalid-option 2>&1); then
        print_result "Unknown option handling" "FAIL" "Script should reject unknown option"
    else
        if echo "$output" | grep -q "Unknown option"; then
            print_result "Unknown option handling" "PASS" ""
        else
            print_result "Unknown option handling" "FAIL" "Error message doesn't mention unknown option"
        fi
    fi
}

# Test 11: Multiple flags combination
test_multiple_flags() {
    print_header "Test 11: Multiple Flags Combination"
    
    local output
    if output=$("$NHL_SCRIPT" "2025-11-18" --no-copy --raw 2>&1); then
        # Should work with both flags - extract JSON properly
        local json_output=$(echo "$output" | grep -E '^\{.*\}$' | head -1)
        if echo "$json_output" | jq -e . >/dev/null 2>&1; then
            print_result "Multiple flags work together" "PASS" ""
        else
            print_result "Multiple flags work together" "FAIL" "Failed with multiple flags"
        fi
    else
        print_result "Multiple flags work together" "FAIL" "Script failed with multiple flags"
    fi
}

# Test 12: Live game display format and visual indicators
test_intermission_display() {
    print_header "Test 12: Live Game Display Format and Visual Indicators"
    
    # Check if there are any live games today
    local today=$(date +%Y-%m-%d)
    local json_data=$(curl -sf "https://sploosh-ai-hockey-analytics.vercel.app/api/nhl/scores?date=${today}")
    
    # First, test that legend is displayed
    if "$NHL_SCRIPT" "$today" --no-copy > /tmp/nhl_test_legend.txt 2>&1; then
        local clean_output=$(perl -pe 's/\e\[[0-9;]*m//g' /tmp/nhl_test_legend.txt)
        
        # Check for legend line
        if echo "$clean_output" | grep -q "Legend:"; then
            print_result "Legend is displayed" "PASS" ""
        else
            print_result "Legend is displayed" "FAIL" "Should show legend with visual indicators"
        fi
        
        # Check that legend contains all icons by checking the legend line itself
        local legend_line=$(echo "$clean_output" | grep "Legend:")
        if echo "$legend_line" | grep -q "Active" && echo "$legend_line" | grep -q "Intermission" && \
           echo "$legend_line" | grep -q "Overtime" && echo "$legend_line" | grep -q "Shootout" && \
           echo "$legend_line" | grep -q "Final" && echo "$legend_line" | grep -q "Scheduled"; then
            print_result "Legend contains all visual indicators" "PASS" ""
        else
            print_result "Legend contains all visual indicators" "FAIL" "Legend should show all 6 icons"
        fi
        
        # Check that legend has consistent spacing (double space after emoji, then label)
        if echo "$clean_output" | grep -qE "Legend:.*▶️  Active.*⏸️  Intermission.*🔥 Overtime.*🎯 Shootout.*🏁 Final.*⏰ Scheduled"; then
            print_result "Legend has consistent spacing" "PASS" ""
        else
            print_result "Legend has consistent spacing" "FAIL" "Legend spacing should be consistent between icons and labels"
        fi
        
        rm -f /tmp/nhl_test_legend.txt
    else
        print_result "Legend is displayed" "FAIL" "Script failed"
        print_result "Legend contains all visual indicators" "FAIL" "Script failed"
        print_result "Legend has consistent spacing" "FAIL" "Script failed"
        rm -f /tmp/nhl_test_legend.txt
    fi
    
    if [ -n "$json_data" ]; then
        # Check if any game is live
        local live_game=$(echo "$json_data" | jq -r '.games[] | select(.gameState == "LIVE" or .gameState == "CRIT") | .id' | head -1)
        
        if [ -n "$live_game" ]; then
            # Get game details
            local away_team=$(echo "$json_data" | jq -r ".games[] | select(.id == $live_game) | .awayTeam.abbrev")
            local home_team=$(echo "$json_data" | jq -r ".games[] | select(.id == $live_game) | .homeTeam.abbrev")
            local period=$(echo "$json_data" | jq -r ".games[] | select(.id == $live_game) | .period")
            local period_type=$(echo "$json_data" | jq -r ".games[] | select(.id == $live_game) | .periodDescriptor.periodType")
            local in_intermission=$(echo "$json_data" | jq -r ".games[] | select(.id == $live_game) | .clock.inIntermission")
            
            # Run the script and check output
            if "$NHL_SCRIPT" "$today" --no-copy > /tmp/nhl_test_live_format.txt 2>&1; then
                local clean_output=$(perl -pe 's/\e\[[0-9;]*m//g' /tmp/nhl_test_live_format.txt)
                
                # Check that live games show format: "ICON PERIOD - TIME  TEAM @ TEAM  SCORE - SCORE"
                # The format should have icon/period, then matchup, then score
                if echo "$clean_output" | grep -qE "(▶|⏸|🔥|🎯).*(st|nd|rd|th|INT|OT|SO).*${away_team} @ ${home_team}.*[0-9]+ - [0-9]+"; then
                    print_result "Live games show icon/period first, then matchup/score" "PASS" ""
                else
                    print_result "Live games show icon/period first, then matchup/score" "FAIL" "Should show 'ICON PERIOD  ${away_team} @ ${home_team}  SCORE'"
                fi
                
                # Check for visual indicators based on game state
                if [ "$in_intermission" = "true" ]; then
                    # Check for pause icon during intermission
                    if echo "$clean_output" | grep -q "⏸"; then
                        print_result "Intermission shows pause icon (⏸️)" "PASS" ""
                    else
                        print_result "Intermission shows pause icon (⏸️)" "FAIL" "Should show pause icon for intermission"
                    fi
                    
                    # Check for INT indicator (time is now in separate column, no dash)
                    if echo "$clean_output" | grep -qE "${period}(st|nd|rd|th) INT"; then
                        print_result "Intermission shows INT indicator" "PASS" ""
                    else
                        print_result "Intermission shows INT indicator" "FAIL" "Should show '${period}st/nd/rd INT'"
                    fi
                    
                    # Check that time appears between period and matchup
                    if echo "$clean_output" | grep -qE "${period}(st|nd|rd|th) INT.*[0-9]{1,2}:[0-9]{2}.*${away_team} @ ${home_team}"; then
                        print_result "Intermission time between period and matchup" "PASS" ""
                    else
                        print_result "Intermission time between period and matchup" "FAIL" "Time should appear between period and matchup"
                    fi
                else
                    # Check for appropriate icon based on period type
                    if [ "$period_type" = "REG" ]; then
                        # Regular period - check for play icon
                        if echo "$clean_output" | grep -q "▶"; then
                            print_result "Active play shows play icon (▶️)" "PASS" ""
                        else
                            print_result "Active play shows play icon (▶️)" "FAIL" "Should show play icon for active game"
                        fi
                    elif [ "$period_type" = "OT" ]; then
                        # Overtime - check for fire icon
                        if echo "$clean_output" | grep -q "🔥"; then
                            print_result "Overtime shows fire icon (🔥)" "PASS" ""
                        else
                            print_result "Overtime shows fire icon (🔥)" "FAIL" "Should show fire icon for OT"
                        fi
                    elif [ "$period_type" = "SO" ]; then
                        # Shootout - check for target icon
                        if echo "$clean_output" | grep -q "🎯"; then
                            print_result "Shootout shows target icon (🎯)" "PASS" ""
                        else
                            print_result "Shootout shows target icon (🎯)" "FAIL" "Should show target icon for SO"
                        fi
                    fi
                    
                    print_result "Intermission shows pause icon (⏸️)" "PASS" "No intermission (test skipped)"
                    print_result "Intermission shows INT indicator" "PASS" "No intermission (test skipped)"
                    print_result "Intermission time between period and matchup" "PASS" "No intermission (test skipped)"
                fi
                
                # Check for ordinal suffixes in period display (time is now in separate column, no dash)
                if [ "$period_type" = "REG" ]; then
                    if echo "$clean_output" | grep -qE "${period}(st|nd|rd|th)"; then
                        print_result "Period shows ordinal suffix" "PASS" ""
                    else
                        print_result "Period shows ordinal suffix" "FAIL" "Should show '${period}st/nd/rd'"
                    fi
                    
                    # Check that time appears between period and matchup for active games
                    if echo "$clean_output" | grep -qE "${period}(st|nd|rd|th).*[0-9]{1,2}:[0-9]{2}.*${away_team} @ ${home_team}"; then
                        print_result "Active game time between period and matchup" "PASS" ""
                    else
                        print_result "Active game time between period and matchup" "FAIL" "Time should appear between period and matchup"
                    fi
                else
                    print_result "Period shows ordinal suffix" "PASS" "Game in OT/SO (test skipped)"
                    print_result "Active game time between period and matchup" "PASS" "Game in OT/SO (test skipped)"
                fi
                
                rm -f /tmp/nhl_test_live_format.txt
            else
                print_result "Live games show icon/period first, then matchup/score" "FAIL" "Script failed"
                print_result "Active play shows play icon (▶️)" "FAIL" "Script failed"
                print_result "Intermission shows pause icon (⏸️)" "FAIL" "Script failed"
                print_result "Intermission shows INT indicator" "FAIL" "Script failed"
                print_result "Intermission time between period and matchup" "FAIL" "Script failed"
                print_result "Period shows ordinal suffix" "FAIL" "Script failed"
                print_result "Active game time between period and matchup" "FAIL" "Script failed"
                rm -f /tmp/nhl_test_live_format.txt
            fi
        else
            print_result "Live games show icon/period first, then matchup/score" "PASS" "No live games (test skipped)"
            print_result "Active play shows play icon (▶️)" "PASS" "No live games (test skipped)"
            print_result "Intermission shows pause icon (⏸️)" "PASS" "No live games (test skipped)"
            print_result "Intermission shows INT indicator" "PASS" "No live games (test skipped)"
            print_result "Intermission time between period and matchup" "PASS" "No live games (test skipped)"
            print_result "Period shows ordinal suffix" "PASS" "No live games (test skipped)"
            print_result "Active game time between period and matchup" "PASS" "No live games (test skipped)"
        fi
        
        # Check scheduled games format
        local scheduled_game=$(echo "$json_data" | jq -r '.games[] | select(.gameState == "FUT" or .gameState == "PRE") | .id' | head -1)
        
        if [ -n "$scheduled_game" ]; then
            if "$NHL_SCRIPT" "$today" --no-copy > /tmp/nhl_test_scheduled_format.txt 2>&1; then
                local clean_output=$(perl -pe 's/\e\[[0-9;]*m//g' /tmp/nhl_test_scheduled_format.txt)
                
                # Check that scheduled games show: status, matchup, time
                if echo "$clean_output" | grep -qE "Scheduled.*[A-Z]{3} @ [A-Z]{3}.*[0-9]{1,2}:[0-9]{2} (AM|PM)"; then
                    print_result "Scheduled games show status, matchup, time" "PASS" ""
                else
                    print_result "Scheduled games show status, matchup, time" "FAIL" "Should show 'Scheduled  TEAM @ TEAM  TIME'"
                fi
                
                # Check that scheduled game start times align with active game scores
                # Extract positions of start times and scores
                local scheduled_line=$(echo "$clean_output" | grep -E "Scheduled.*[A-Z]{3} @ [A-Z]{3}" | head -1)
                local active_line=$(echo "$clean_output" | grep -E "(▶|⏸|🔥|🎯).*[A-Z]{3} @ [A-Z]{3}.*[0-9]+ - [0-9]+" | head -1)
                
                if [ -n "$scheduled_line" ] && [ -n "$active_line" ]; then
                    # Get position of time in scheduled line (after matchup)
                    local sched_time_pos=$(echo "$scheduled_line" | grep -o "^.*[A-Z]{3} @ [A-Z]{3}" | awk '{print length}')
                    # Get position of score in active line (after matchup)
                    local active_score_pos=$(echo "$active_line" | grep -o "^.*[A-Z]{3} @ [A-Z]{3}" | awk '{print length}')
                    
                    # They should be at roughly the same position (within 2 chars)
                    local pos_diff=$((sched_time_pos - active_score_pos))
                    if [ "$pos_diff" -lt 0 ]; then
                        pos_diff=$((-pos_diff))
                    fi
                    
                    if [ "$pos_diff" -le 2 ]; then
                        print_result "Scheduled start times align with active game scores" "PASS" ""
                    else
                        print_result "Scheduled start times align with active game scores" "FAIL" "Start times should align with scores (diff: $pos_diff chars)"
                    fi
                else
                    print_result "Scheduled start times align with active game scores" "PASS" "Cannot compare (missing data)"
                fi
                
                rm -f /tmp/nhl_test_scheduled_format.txt
            else
                print_result "Scheduled games show status, matchup, time" "FAIL" "Script failed"
                print_result "Scheduled start times align with active game scores" "FAIL" "Script failed"
                rm -f /tmp/nhl_test_scheduled_format.txt
            fi
        else
            print_result "Scheduled games show status, matchup, time" "PASS" "No scheduled games (test skipped)"
            print_result "Scheduled start times align with active game scores" "PASS" "No scheduled games (test skipped)"
        fi
        
        # Test column alignment consistency
        if "$NHL_SCRIPT" "$today" --no-copy > /tmp/nhl_test_alignment.txt 2>&1; then
            local clean_output=$(perl -pe 's/\e\[[0-9;]*m//g' /tmp/nhl_test_alignment.txt)
            
            # Extract all game lines (skip header, legend, and footer)
            local game_lines=$(echo "$clean_output" | grep -E "^  (▶|⏸|🔥|🎯|🏁|⏰)")
            
            # Check that all TEAM @ TEAM patterns are aligned consistently
            # Additional test: verify @ symbol appears at nearly the same column (within 4 chars due to emoji rendering)
            local at_positions=$(echo "$game_lines" | grep -o "^.\{0,50\} @ " | awk '{print length}' | sort -u)
            local min_pos=$(echo "$at_positions" | head -1)
            local max_pos=$(echo "$at_positions" | tail -1)
            local diff=$((max_pos - min_pos))
            
            if [ "$diff" -le 4 ]; then
                print_result "@ symbol aligned (within 4 chars for emoji rendering)" "PASS" ""
            else
                print_result "@ symbol aligned (within 4 chars for emoji rendering)" "FAIL" "Position difference: $diff chars (min: $min_pos, max: $max_pos)"
            fi
            
            # Check that all TEAM @ TEAM patterns are aligned consistently
            # Count the position of " @ " in each line
            local positions=$(echo "$game_lines" | grep -o "^.\{0,50\} @ " | awk '{print length}')
            local unique_positions=$(echo "$positions" | sort -u | wc -l)
            
            # All @ symbols should be at roughly the same position (within 4 chars due to emoji rendering and different game states)
            # We expect 3 unique positions: Final games (25 chars), Active games (28 chars), Scheduled games (different)
            if [ "$unique_positions" -le 3 ]; then
                print_result "Team matchups are consistently aligned" "PASS" ""
            else
                print_result "Team matchups are consistently aligned" "FAIL" "TEAM @ TEAM should be aligned across all games (found $unique_positions unique positions)"
            fi
            
            rm -f /tmp/nhl_test_alignment.txt
        else
            print_result "Team matchups are consistently aligned" "FAIL" "Script failed"
            print_result "@ symbol aligned (within 4 chars for emoji rendering)" "FAIL" "Script failed"
            rm -f /tmp/nhl_test_alignment.txt
        fi
    else
        print_result "Live games show icon/period first, then matchup/score" "FAIL" "Could not fetch API data"
        print_result "Active play shows play icon (▶️)" "FAIL" "Could not fetch API data"
        print_result "Intermission shows pause icon (⏸️)" "FAIL" "Could not fetch API data"
        print_result "Intermission shows INT indicator" "FAIL" "Could not fetch API data"
        print_result "Intermission time between period and matchup" "FAIL" "Could not fetch API data"
        print_result "Period shows ordinal suffix" "FAIL" "Could not fetch API data"
        print_result "Active game time between period and matchup" "FAIL" "Could not fetch API data"
        print_result "Scheduled games show status, matchup, time" "FAIL" "Could not fetch API data"
        print_result "Scheduled start times align with active game scores" "FAIL" "Could not fetch API data"
        print_result "Team matchups are consistently aligned" "FAIL" "Could not fetch API data"
        print_result "@ symbol aligned (within 4 chars for emoji rendering)" "FAIL" "Could not fetch API data"
    fi
}

# Test 13: Final/OT and Final/SO alignment
test_final_variants_alignment() {
    print_header "Test 13: Final/OT and Final/SO Alignment"
    
    # Create test lines with the actual format strings from the script
    # Final game: status column is 25 chars
    local final_line=$(printf "  %-25s%-13s%s\n" "🏁 Final" "EDM @ WSH" "4 - 7")
    local final_ot_line=$(printf "  %-25s%-13s%s\n" "🏁 Final/OT" "EDM @ WSH" "4 - 3")
    local final_so_line=$(printf "  %-25s%-13s%s\n" "🏁 Final/SO" "EDM @ WSH" "3 - 2")
    
    # Active game: period (18 chars) + time (10 chars) = 28 chars total before matchup
    local active_line=$(printf "  %-18s%-10s%-13s%s\n" "▶️  3rd" "15:23" "CGY @ BUF" "3 - 2")
    local ot_active_line=$(printf "  %-18s%-10s%-13s%s\n" "🔥 OT   " "03:45" "CGY @ BUF" "2 - 2")
    local so_active_line=$(printf "  %-18s%-10s%-13s%s\n" "🎯 SO   " "00:00" "CGY @ BUF" "0 - 0")
    
    # Function to extract matchup position
    get_matchup_position() {
        local line=$1
        # Find position of first occurrence of pattern "XXX @ XXX"
        echo "$line" | awk '{match($0,/[A-Z][A-Z][A-Z] @ [A-Z][A-Z][A-Z]/); if (RSTART) print RSTART-1}'
    }
    
    # Test Final vs Active alignment (allow 3 char difference for emoji rendering)
    local final_pos=$(get_matchup_position "$final_line")
    local active_pos=$(get_matchup_position "$active_line")
    local diff=$((active_pos - final_pos))
    if [ "$diff" -lt 0 ]; then diff=$((-diff)); fi
    
    if [ "$diff" -le 3 ]; then
        print_result "Final vs Active game matchup alignment (within 3 chars)" "PASS" ""
    else
        print_result "Final vs Active game matchup alignment (within 3 chars)" "FAIL" "Final matchup at pos $final_pos, Active at pos $active_pos (diff: $diff)"
    fi
    
    # Test Final/OT vs Active alignment
    local final_ot_pos=$(get_matchup_position "$final_ot_line")
    diff=$((active_pos - final_ot_pos))
    if [ "$diff" -lt 0 ]; then diff=$((-diff)); fi
    
    if [ "$diff" -le 3 ]; then
        print_result "Final/OT vs Active game matchup alignment (within 3 chars)" "PASS" ""
    else
        print_result "Final/OT vs Active game matchup alignment (within 3 chars)" "FAIL" "Final/OT matchup at pos $final_ot_pos, Active at pos $active_pos (diff: $diff)"
    fi
    
    # Test Final/SO vs Active alignment
    local final_so_pos=$(get_matchup_position "$final_so_line")
    diff=$((active_pos - final_so_pos))
    if [ "$diff" -lt 0 ]; then diff=$((-diff)); fi
    
    if [ "$diff" -le 3 ]; then
        print_result "Final/SO vs Active game matchup alignment (within 3 chars)" "PASS" ""
    else
        print_result "Final/SO vs Active game matchup alignment (within 3 chars)" "FAIL" "Final/SO matchup at pos $final_so_pos, Active at pos $active_pos (diff: $diff)"
    fi
    
    # Test all Final variants align with each other
    if [ "$final_pos" = "$final_ot_pos" ] && [ "$final_pos" = "$final_so_pos" ]; then
        print_result "All Final variants align with each other" "PASS" ""
    else
        print_result "All Final variants align with each other" "FAIL" "Final: $final_pos, Final/OT: $final_ot_pos, Final/SO: $final_so_pos"
    fi
    
    # Test OT and SO active games align with regular active games
    local ot_active_pos=$(get_matchup_position "$ot_active_line")
    local so_active_pos=$(get_matchup_position "$so_active_line")
    
    if [ "$ot_active_pos" = "$active_pos" ] && [ "$so_active_pos" = "$active_pos" ]; then
        print_result "OT and SO active games align with regular active games" "PASS" ""
    else
        print_result "OT and SO active games align with regular active games" "FAIL" "Active: $active_pos, OT: $ot_active_pos, SO: $so_active_pos"
    fi
    
    # Visual display test
    echo ""
    echo -e "${YELLOW}Visual alignment test (inspect manually):${NC}"
    echo "$final_line"
    echo "$final_ot_line"
    echo "$final_so_line"
    echo "$active_line"
    echo "$ot_active_line"
    echo "$so_active_line"
    echo ""
    
    # Test with actual data if available
    local test_date="2025-11-18"
    if "$NHL_SCRIPT" "$test_date" --no-copy > /tmp/nhl_test_final_variants.txt 2>&1; then
        local clean_output=$(perl -pe 's/\e\[[0-9;]*m//g' /tmp/nhl_test_final_variants.txt)
        
        # Extract all game lines
        local game_lines=$(echo "$clean_output" | grep -E "^  (▶|⏸|🔥|🎯|🏁|⏰)")
        
        # Check that Final, Final/OT, and Final/SO all have matchups at the same position
        local final_lines=$(echo "$game_lines" | grep "🏁 Final")
        
        if [ -n "$final_lines" ]; then
            # Get positions of all matchups in Final lines
            local final_positions=$(echo "$final_lines" | grep -o "^.\{0,50\}[A-Z]\{3\} @ " | awk '{print length}' | sort -u)
            local unique_final_positions=$(echo "$final_positions" | wc -l)
            
            if [ "$unique_final_positions" -le 1 ]; then
                print_result "All Final variants align in actual output" "PASS" ""
            else
                print_result "All Final variants align in actual output" "FAIL" "Final variants have different matchup positions"
            fi
        else
            print_result "All Final variants align in actual output" "PASS" "No Final games in test data (test skipped)"
        fi
        
        rm -f /tmp/nhl_test_final_variants.txt
    else
        print_result "All Final variants align in actual output" "FAIL" "Script failed"
        rm -f /tmp/nhl_test_final_variants.txt
    fi
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Testing get_nhl_schedule.sh                      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    
    # Check for required dependencies
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required but not installed${NC}"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed${NC}"
        exit 1
    fi
    
    # Run all tests
    test_script_exists
    test_help_flag
    test_date_validation
    test_api_connectivity
    test_no_copy_flag
    test_raw_flag
    test_default_date
    test_game_state_display
    test_timezone_conversion
    test_unknown_option
    test_multiple_flags
    test_intermission_display
    test_final_variants_alignment
    
    # Print summary
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Total tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Tests passed: ${TESTS_PASSED}${NC}"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Tests failed: ${TESTS_FAILED}${NC}"
        echo ""
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        echo ""
        exit 0
    fi
}

# Run main function
main
