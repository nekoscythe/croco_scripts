#!/bin/bash

# Function to get the root directory of the project by looking for settings.yaml
get_root_dir() {
    DIR="$(pwd)"
    while [[ ! -f "$DIR/settings.yaml" && "$DIR" != "/" ]]; do
        DIR=$(dirname "$DIR")
    done

    if [[ -f "$DIR/settings.yaml" ]]; then
        echo "$DIR"
    else
        echo "Error: Root directory not found. Ensure settings.yaml exists in the project root."
        exit 1
    fi
}

# Function to extract the tests_dir value using yq
get_tests_dir() {
    ROOT_DIR=$(get_root_dir)
    TESTS_DIR=$(yq eval '.project.tests_dir' "$ROOT_DIR/settings.yaml" -o=json | yq eval -r '.')
    echo "$TESTS_DIR"
}

# Function to list all subtests recursively and display them as a tree with changes
display_test_tree() {
    local TEST_DIR="$1"
    local PREFIX="$2"

    # Print the test name
    # echo "$TEST_DIR"

    # Check if metadata.yaml exists in the current test directory
    if [[ -f "$TEST_DIR/metadata.yaml" ]]; then
        # Extract test name from metadata.yaml
        local TEST_NAME
        TEST_NAME=$(yq eval '.test_name' "$TEST_DIR/metadata.yaml" -o=json | yq eval -r '.')
        echo "${PREFIX}└── ${TEST_NAME}"

        # Display the dependencies (changes) between the tests
        local DEPENDENCIES
        DEPENDENCIES=$(yq eval '.dependencies' "$TEST_DIR/metadata.yaml" -o=json | yq eval -r '.[]')
        for DEPENDENCY in $DEPENDENCIES; do
            echo "${PREFIX}    ├── $DEPENDENCY"
   

    fi

    # Recursively check for subtests in the subtests directory
    local SUBTESTS_DIR="$TEST_DIR/subtests"
    if [[ -d "$SUBTESTS_DIR" ]]; then
        local SUBTEST_PATHS
        IFS=$'\n' read -rd '' -a SUBTEST_PATHS <<< "$(find "$SUBTESTS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)"

        for SUBTEST_PATH in "${SUBTEST_PATHS[@]}"; do
            # Properly handle subtest directories with spaces
            display_test_tree "$SUBTEST_PATH" "${PREFIX}    "
        done
    fi
}

# Main function to display the test tree
display_tests_tree() {
    ROOT_DIR=$(get_root_dir)
    SETTINGS_FILE="$ROOT_DIR/settings.yaml"
    
    # Retrieve the tests directory from settings.yaml
    TESTS_DIR=$(get_tests_dir)

    # Check if the tests directory exists
    if [[ -z "$TESTS_DIR" || ! -d "$ROOT_DIR/$TESTS_DIR" ]]; then
        echo "Error: Tests directory not found in the project. Check the value of 'tests_dir' in settings.yaml."
        exit 1
    fi

    TESTS_PATH="$ROOT_DIR/$TESTS_DIR"
    echo "Project Test Tree:"
    echo

    # List all top-level tests
    IFS=$'\n' read -rd '' -a TOP_TESTS <<< "$(find "$TESTS_PATH" -mindepth 1 -maxdepth 1 -type d | sort)"
    for TEST_PATH in "${TOP_TESTS[@]}"; do
        # Properly handle test directories with spaces
        display_test_tree "$TEST_PATH" ""
    done
}

# Run the function to display the tree structure
display_tests_tree
