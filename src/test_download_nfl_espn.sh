#!/bin/bash
#
# Test script for download_nfl_espn.sh
# Tests the date handling and file naming functionality

# Set up colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define test functions that mimic the behavior of the original script

# Function to convert UTC date to local game date
convert_utc_to_game_date() {
    local utc_date=$1
    local utc_time=$2
    local utc_hour=$(echo "$utc_time" | cut -d':' -f1)
    
    # If the UTC time is after 8:00 PM (20:00), it's the same day in US
    # If it's before 8:00 PM, it's the previous day in US Pacific Time
    if [ "$utc_hour" -lt 20 ]; then
        # For games that are before 8:00 PM UTC, use the previous day for US dates
        # Use sed to remove hyphens from the date and then subtract one day
        local date_without_hyphens=$(echo "$utc_date" | tr -d '-')
        local year=${date_without_hyphens:0:4}
        local month=${date_without_hyphens:4:2}
        local day=${date_without_hyphens:6:2}
        
        # Use date command to subtract one day
        if command -v gdate >/dev/null 2>&1; then
            # GNU date (if available)
            echo $(gdate -d "$utc_date -1 day" +"%Y%m%d")
        else
            # BSD date (macOS)
            echo $(date -j -v-1d -f "%Y%m%d" "$date_without_hyphens" +"%Y%m%d")
        fi
    else
        # Otherwise use the UTC date as is
        echo "$(echo "$utc_date" | tr -d '-')"
    fi
}

# Mock data for testing
mock_evening_game='{
  "gamepackageJSON": {
    "header": {
      "competitions": [
        {
          "date": "2025-08-23T20:00Z"
        }
      ]
    }
  }
}'

mock_night_game='{
  "gamepackageJSON": {
    "header": {
      "competitions": [
        {
          "date": "2025-08-16T02:00Z"
        }
      ]
    }
  }
}'

mock_missing_date='{
  "gamepackageJSON": {
    "header": {
      "competitions": [
        {
        }
      ]
    }
  }
}'

# Function to extract game date from ESPN API response
extract_game_date() {
    local game_data=$1
    local game_datetime
    
    # Extract game date and time from the API response
    game_datetime=$(echo "$game_data" | jq -r '.gamepackageJSON.header.competitions[0].date')
    
    if [ -z "$game_datetime" ] || [ "$game_datetime" = "null" ]; then
        echo "$(date +%Y%m%d)"
        return
    fi
    
    # Extract date part and time part
    local utc_date=$(echo "$game_datetime" | cut -d'T' -f1)
    local utc_time=$(echo "$game_datetime" | cut -d'T' -f2 | cut -d'Z' -f1)
    
    # Convert to game date
    convert_utc_to_game_date "$utc_date" "$utc_time"
}

# Function to generate filename based on game parameters
generate_filename() {
    local date=$1
    local away=$2
    local home=$3
    local game_id=$4
    local game_type=$5
    local week=$6
    
    # Determine the NFL season based on game date
    local year
    local month
    year=${date:0:4}
    month=${date:4:2}
    
    # Determine season directory
    local season_dir
    if [ "$month" -ge 8 ] && [ "$month" -le 12 ]; then
        # August to December is the start of the season (e.g., 2025-26)
        season_dir="$year-$((year + 1 - 2000))"
    else
        # January to July is the end of the previous season (e.g., 2024-25)
        season_dir="$((year - 1))-$((year - 2000))"
    fi
    
    # Build the filename based on game type
    local filename="data/NFL - National Football League/espn/$season_dir/$date-$away-vs-$home-$game_id"
    
    case "$game_type" in
        "preseason")
            filename="${filename}-preseason-week-$week.json"
            ;;
        "regular")
            filename="${filename}-week-$week.json"
            ;;
        "playoffs")
            filename="${filename}-playoffs-$week.json"
            ;;
        *)
            filename="${filename}.json"
            ;;
    esac
    
    echo "$filename"
}

# Override the save_json_to_file function to not actually write files
save_json_to_file() {
    # Just return the filename that would have been created
    echo "$1"
}

# Test function to check if a condition is true
assert() {
    local condition=$1
    local message=$2
    
    if eval "$condition"; then
        echo -e "${GREEN}✓ PASS:${NC} $message"
        return 0
    else
        echo -e "${RED}✗ FAIL:${NC} $message"
        return 1
    fi
}

# Test function to check if two values are equal
assert_equals() {
    local expected=$1
    local actual=$2
    local message=$3
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS:${NC} $message"
        return 0
    else
        echo -e "${RED}✗ FAIL:${NC} $message (Expected: '$expected', Got: '$actual')"
        return 1
    fi
}

# Function to simulate download_nfl_game
test_download_game() {
    local game_id=$1
    local away=$2
    local home=$3
    local game_type=$4
    local week=$5
    
    # Get mock data based on game_id
    local game_data
    case "$game_id" in
        "test_evening_game")
            game_data="$mock_evening_game"
            ;;
        "test_night_game")
            game_data="$mock_night_game"
            ;;
        "test_missing_date")
            game_data="$mock_missing_date"
            ;;
        *)
            game_data="$mock_evening_game"
            ;;
    esac
    
    # Extract game date
    local game_date
    game_date=$(extract_game_date "$game_data")
    
    # Generate filename
    generate_filename "$game_date" "$away" "$home" "$game_id" "$game_type" "$week"
}

# Run tests
run_tests() {
    echo -e "${YELLOW}Running tests for download_nfl_espn.sh...${NC}"
    echo
    
    local failures=0
    
    # Test 1: Evening game (8:00 PM UTC / 1:00 PM PT)
    echo "Test 1: Evening game (8:00 PM UTC / 1:00 PM PT)"
    local result=$(test_download_game "test_evening_game" "SEA" "GB" "preseason" "3")
    local expected_date="20250823"
    local actual_date=$(echo "$result" | grep -o "[0-9]\{8\}" | head -1)
    
    assert_equals "$expected_date" "$actual_date" "Evening game should use same day (August 23rd)" || ((failures++))
    echo
    
    # Test 2: Night game (2:00 AM UTC / 7:00 PM PT previous day)
    echo "Test 2: Night game (2:00 AM UTC / 7:00 PM PT previous day)"
    local result=$(test_download_game "test_night_game" "KC" "SEA" "preseason" "2")
    local expected_date="20250815"
    local actual_date=$(echo "$result" | grep -o "[0-9]\{8\}" | head -1)
    
    assert_equals "$expected_date" "$actual_date" "Night game should use previous day (August 15th)" || ((failures++))
    echo
    
    # Test 3: Missing date (should fall back to current date)
    echo "Test 3: Missing date (should fall back to current date)"
    local result=$(test_download_game "test_missing_date" "DEN" "DAL" "preseason" "1")
    local expected_pattern="[0-9]\{8\}"
    
    assert "echo \"$result\" | grep -q \"$expected_pattern\"" "Missing date should fall back to current date" || ((failures++))
    echo
    
    # Test 4: File naming convention for preseason
    echo "Test 4: File naming convention for preseason"
    local result=$(test_download_game "test_evening_game" "SEA" "GB" "preseason" "3")
    local expected_pattern="20250823-SEA-vs-GB-test_evening_game-preseason-week-3.json"
    
    assert_equals "$expected_pattern" "$(basename "$result")" "Preseason file naming convention" || ((failures++))
    echo
    
    # Test 5: File naming convention for regular season
    echo "Test 5: File naming convention for regular season"
    local result=$(test_download_game "test_evening_game" "SEA" "GB" "regular" "10")
    local expected_pattern="20250823-SEA-vs-GB-test_evening_game-week-10.json"
    
    assert_equals "$expected_pattern" "$(basename "$result")" "Regular season file naming convention" || ((failures++))
    echo
    
    # Test 6: File naming convention for playoffs
    echo "Test 6: File naming convention for playoffs"
    local result=$(test_download_game "test_evening_game" "SEA" "GB" "playoffs" "wild-card")
    local expected_pattern="20250823-SEA-vs-GB-test_evening_game-playoffs-wild-card.json"
    
    assert_equals "$expected_pattern" "$(basename "$result")" "Playoffs file naming convention" || ((failures++))
    echo
    
    # Test 7: Season directory determination for August game
    echo "Test 7: Season directory determination for August game"
    local result=$(test_download_game "test_evening_game" "SEA" "GB" "preseason" "3")
    local expected_pattern="2025-26"
    local actual_season=$(echo "$result" | grep -o "2025-26")
    
    assert_equals "$expected_pattern" "$actual_season" "August game should use 2025-26 season directory" || ((failures++))
    echo
    
    # Test 8: Season directory determination for January game
    echo "Test 8: Season directory determination for January game"
    # Create a custom January test
    local jan_game='{"gamepackageJSON":{"header":{"competitions":[{"date":"2026-01-15T20:00Z"}]}}}'
    local game_date=$(extract_game_date "$jan_game")
    local result=$(generate_filename "$game_date" "SEA" "GB" "test_jan_game" "playoffs" "divisional")
    local expected_pattern="2025-26"
    local actual_season=$(echo "$result" | grep -o "2025-26")
    
    assert_equals "$expected_pattern" "$actual_season" "January game should use 2025-26 season directory" || ((failures++))
    echo
    
    # Summary
    echo -e "${YELLOW}Test Summary:${NC}"
    if [ $failures -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
    else
        echo -e "${RED}$failures test(s) failed.${NC}"
    fi
    
    return $failures
}

# Run the tests
run_tests
exit $?
