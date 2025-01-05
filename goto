#!/bin/bash

# Function to get the root directory of the project by looking for settings.yaml
get_root_dir() {
    local DIR="$(pwd)"
    while [[ ! -f "$DIR/settings.yaml" && "$DIR" != "/" ]]; do
        DIR=$(dirname "$DIR")
    done

    if [[ -f "$DIR/settings.yaml" ]]; then
        echo "$DIR"
    else
        echo "Error: Root directory not found. Ensure settings.yaml exists in the project root."
        return 1
    fi
}

# Function to find the tests directory from the settings.yaml file using yq
get_tests_dir() {
    local ROOT_DIR="$1"
    local SETTINGS_FILE="$ROOT_DIR/settings.yaml"
    yq eval '.project.tests_dir' "$SETTINGS_FILE" | xargs
}

# Function to find all test directories matching the given name
find_all_test_directories() {
    local TEST_NAME="$1"
    local SEARCH_DIR="$2"

    local MATCHES=()
    while IFS= read -r METADATA_PATH; do
        if [[ -f "$METADATA_PATH" ]]; then
            # Extract test_name from the metadata.yaml file using yq
            local CURRENT_TEST_NAME
            CURRENT_TEST_NAME=$(yq eval '.test_name' "$METADATA_PATH" | xargs)

            if [[ "$CURRENT_TEST_NAME" == "$TEST_NAME" ]]; then
                MATCHES+=("$(dirname "$METADATA_PATH")")
            fi
        fi
    done < <(find "$SEARCH_DIR" -name metadata.yaml 2>/dev/null)

    echo "${MATCHES[@]}"
}

# Main function to navigate to a test
go_to_test() {
    local TEST_NAME="$1"
    local ROOT_DIR
    ROOT_DIR=$(get_root_dir) || return 1

    local TESTS_DIR
    TESTS_DIR=$(get_tests_dir "$ROOT_DIR")

    # If no argument is provided, navigate to the root test directory
    if [[ -z "$TEST_NAME" ]]; then
        if [[ -d "$ROOT_DIR/$TESTS_DIR" ]]; then
            echo "Navigating to root test directory: $ROOT_DIR/$TESTS_DIR"
            cd "$ROOT_DIR/$TESTS_DIR" || return 1
        else
            echo "Error: Tests directory not found in the project."
            return 1
        fi
        return 0
    fi

    local TESTS_PATH="$ROOT_DIR/$TESTS_DIR"

    # Ensure the tests directory exists
    if [[ ! -d "$TESTS_PATH" ]]; then
        echo "Error: Tests directory not found in the project."
        return 1
    fi

    # Find all matching test directories
    local MATCHING_DIRECTORIES
    IFS=$'\n' MATCHING_DIRECTORIES=($(find_all_test_directories "$TEST_NAME" "$TESTS_PATH"))

    if [[ ${#MATCHING_DIRECTORIES[@]} -eq 0 ]]; then
        echo "Error: Test '$TEST_NAME' not found."
        return 1
    elif [[ ${#MATCHING_DIRECTORIES[@]} -eq 1 ]]; then
        # Only one match found
        echo "Navigating to test directory: ${MATCHING_DIRECTORIES[0]}"
        cd "${MATCHING_DIRECTORIES[0]}" || return 1
    else
        # Multiple matches found, prompt user to choose
        echo "Multiple tests found with the name '$TEST_NAME':"
        for i in "${!MATCHING_DIRECTORIES[@]}"; do
            echo "$((i + 1)): ${MATCHING_DIRECTORIES[i]}"
        done

        read -p "Enter the number of the test you want to navigate to: " CHOICE
        if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE > 0 && CHOICE <= ${#MATCHING_DIRECTORIES[@]} )); then
            echo "Navigating to test directory: ${MATCHING_DIRECTORIES[$((CHOICE - 1))]}"
            cd "${MATCHING_DIRECTORIES[$((CHOICE - 1))]}" || return 1
        else
            echo "Invalid choice. Exiting."
            return 1
        fi
    fi
}

# Ensure the script is sourced for `cd` to take effect
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "Error: This script must be sourced to navigate. Use 'source $0 <test_name>'"
    exit 1
fi

# Run the function with the provided test name
go_to_test "$1"
