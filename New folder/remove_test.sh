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

# Function to check if a binary is used by any other test
is_binary_used_by_other_tests() {
    ROOT_DIR="$1"
    BINARIES_DIR="$2"
    BINARY_NAME="$3"

    # Scan through all tests to check if the binary is referenced in metadata
    for TEST_DIR in "$ROOT_DIR"/*; do
        if [[ -d "$TEST_DIR" ]]; then
            METADATA_FILE="$TEST_DIR/metadata.yaml"
            if [[ -f "$METADATA_FILE" ]]; then
                # Check if the binary is mentioned in the test's metadata
                if grep -q "$BINARY_NAME" "$METADATA_FILE"; then
                    # The binary is referenced in this test, so it's still in use
                    return 0
                fi
            fi
        fi
    done

    # Binary is not referenced by any other test
    return 1
}

# Function to find and list all subtests recursively and count them
find_subtests() {
    local PARENT_TEST_PATH=$1
    local SUBTESTS_DIR="$PARENT_TEST_PATH/subtests"

    # Check if the subtests directory exists
    if [[ -d "$SUBTESTS_DIR" ]]; then
        for SUBTEST_PATH in "$SUBTESTS_DIR"/*; do
            # Check if the current path is a directory
            if [[ -d "$SUBTEST_PATH" ]]; then
                # Check for metadata.yaml in the subtest directory
                local METADATA_FILE="$SUBTEST_PATH/metadata.yaml"
                if [[ -f "$METADATA_FILE" ]]; then
                    # Extract the test_name from metadata.yaml
                    local TEST_NAME
                    TEST_NAME=$(awk '/test_name:/ {print $2}' "$METADATA_FILE" | xargs)

                    # Increment the subtest count
                    ((SUBTEST_COUNT++))

                    # Print the subtest details
                    echo "Subtest #$SUBTEST_COUNT"
                    echo "  Name: $TEST_NAME"
                    echo "  Directory: $SUBTEST_PATH"
                    echo

                    # Recursively find subtests of this subtest
                    find_subtests "$SUBTEST_PATH"
                fi
            fi
        done
    fi
}

# Function to remove a test and update any tracking information
remove_test() {
    if [[ -z "$1" ]]; then
        echo "Error: No test name provided."
        exit 1
    fi

    ROOT_DIR=$(get_root_dir)  # Get the root directory of the project
    SETTINGS_FILE="$ROOT_DIR/settings.yaml"

    # Retrieve settings from settings.yaml
    TESTS_DIR=$(awk '/tests_dir:/ {print $2}' "$SETTINGS_FILE" | xargs)
    BINARIES_DIR=$(awk '/binaries_dir:/ {print $2}' "$SETTINGS_FILE" | xargs)

    # Check if the test directory exists
    TEST_PATH="$ROOT_DIR/$TESTS_DIR/$1"
    if [[ ! -d "$TEST_PATH" ]]; then
        echo "Error: Test '$1' does not exist."
        exit 1
    fi

    # Check if the test is a parent test
    matches=$(grep "parent_test: $1" "$ROOT_DIR/$TESTS_DIR"/*/metadata.yaml)

    if [[ $? -eq 0 ]]; then
        echo "Error: Test '$1' is a parent test and cannot be removed."
        echo "Found the following references:"
        echo "$matches"
        exit 1
    fi

    # Confirm the user wants to remove the test and list all subtests with details
    echo "Searching for subtests under test '$1'..."
    SUBTEST_COUNT=0  # Initialize subtest count

    if [[ -d "$TEST_PATH" ]]; then
        echo "Found subtests:"
        find_subtests "$TEST_PATH"
        echo "Total subtests found: $SUBTEST_COUNT"
    else
        echo "Error: Test '$1' does not exist."
        exit 1
    fi

    read -p "Are you sure you want to remove test '$1' and all its subtests? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Test removal aborted."
        exit 0
    fi

    # Remove test metadata and directory
    METADATA_FILE="$TEST_PATH/metadata.yaml"
    if [[ -f "$METADATA_FILE" ]]; then
        echo "Removing metadata for test '$1'..."
        PARENT_TEST=$(grep "parent_test:" "$METADATA_FILE" | awk '{print $2}' | xargs)
        if [[ -n "$PARENT_TEST" ]]; then
            PARENT_TEST_PATH="$ROOT_DIR/$TESTS_DIR/$PARENT_TEST/metadata.yaml"
            if [[ -f "$PARENT_TEST_PATH" ]]; then
                sed -i "s/parent_test: $1/parent_test: null/" "$PARENT_TEST_PATH"
                echo "Updated parent test '$PARENT_TEST' to remove reference to '$1'."
            fi
        fi
        rm "$METADATA_FILE"
        echo "Metadata for test '$1' removed."
    fi

    echo "Removing test directory '$TEST_PATH'..."
    rm -rf "$TEST_PATH"
    echo "Test directory '$TEST_PATH' removed."

    # Check if the binary was unique to this test and remove it if necessary
    BINARY_FILE="$ROOT_DIR/$BINARIES_DIR/$1"
    if [[ -f "$BINARY_FILE" ]]; then
        if is_binary_used_by_other_tests "$ROOT_DIR" "$BINARIES_DIR" "$1"; then
            echo "Binary for test '$1' is still in use by another test. Not removing the binary."
        else
            rm "$BINARY_FILE"
            echo "Binary for test '$1' removed."
        fi
    fi
}

# Run the function with the first argument passed to the script
remove_test "$1"
