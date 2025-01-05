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

# Function to add a branch to the current test folder
add_branch() {
    if [[ -z "$1" ]]; then
        echo "Error: Missing argument. Please provide the branch test name."
        exit 1
    fi

    # Verify if we're in a valid test directory
    if [[ ! -f "metadata.yaml" ]]; then
        echo "Error: No metadata.yaml file found in the current directory. Run the script from a valid test folder."
        exit 1
    fi

    # Extract the test name from the metadata file
    PARENT_TEST_NAME=$(awk '/^test_name:/ {print $2}' metadata.yaml | xargs)
    if [[ -z "$PARENT_TEST_NAME" ]]; then
        echo "Error: Could not find a valid test_name in metadata.yaml."
        exit 1
    fi

    # Define the branch test name and path
    BRANCH_TEST_NAME="$1"
    SUBTESTS_DIR="subtests"
    BRANCH_TEST_PATH="$SUBTESTS_DIR/$BRANCH_TEST_NAME"

    # Ensure the branch test directory does not already exist
    if [[ -d "$BRANCH_TEST_PATH" ]]; then
        echo "Error: Branch test '$BRANCH_TEST_NAME' already exists in the current directory."
        exit 1
    fi

    #Confirm the user wants to create the branch test
    read -p "Create branch test '$BRANCH_TEST_NAME' inside '$PARENT_TEST_NAME'? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Branch test creation aborted."
        exit 0
    fi

    

    # Create the branch test directory and copy necessary files
    mkdir "$BRANCH_TEST_PATH"
    echo "Branch test '$BRANCH_TEST_NAME' created inside '$PARENT_TEST_NAME'."

    # Copy contents of the current test folder (excluding the branch test folder) into the new branch
    find . -mindepth 1 -maxdepth 1 ! -name "$(basename "$SUBTESTS_DIR")" -exec cp -r {} "$BRANCH_TEST_PATH/" \;
    #create subtests directory inside the branch test
    mkdir "$BRANCH_TEST_PATH/$SUBTESTS_DIR"

    # Update metadata for the branch test
    METADATA_FILE="$BRANCH_TEST_PATH/metadata.yaml"
    if [[ -f "$METADATA_FILE" ]]; then
        sed -i "s/^parent_test:.*/parent_test: $PARENT_TEST_NAME/" "$METADATA_FILE"
        sed -i "s/^test_name:.*/test_name: $BRANCH_TEST_NAME/" "$METADATA_FILE"
    else
        cp metadata.yaml "$METADATA_FILE"
        sed -i "s/^test_name:.*/test_name: $BRANCH_TEST_NAME/" "$METADATA_FILE"
        sed -i "s/^parent_test:.*/parent_test: $PARENT_TEST_NAME/" "$METADATA_FILE"
    fi

    echo "Branch test '$BRANCH_TEST_NAME' linked to parent test '$PARENT_TEST_NAME'."
}

# Main script execution
ROOT_DIR=$(get_root_dir)  # Get the root directory of the project
add_branch "$1"  # Add the branch with the provided name