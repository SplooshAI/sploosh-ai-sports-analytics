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
        if echo "$output" | grep -q "NHL Scores Fetcher"; then
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

# Test 8: Unknown option handling
test_unknown_option() {
    print_header "Test 8: Unknown Option Handling"
    
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

# Test 9: Multiple flags combination
test_multiple_flags() {
    print_header "Test 9: Multiple Flags Combination"
    
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
    test_unknown_option
    test_multiple_flags
    
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
