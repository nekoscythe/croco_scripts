#!/bin/bash
# Initialize the project directory structure and settings.

# Function to get the root directory of the project by looking for settings.yaml
get_root_dir() {
    DIR="$(pwd)"
    while [[ ! -f "$DIR/settings.yaml" && "$DIR" != "/" ]]; do
        DIR=$(dirname "$DIR")
    done

    if [[ -f "$DIR/settings.yaml" ]]; then
        echo "$DIR"
    else
        echo "$(pwd)"
        exit 1
    fi
}

# Get the root directory
ROOT_DIR=$(get_root_dir)

# Set paths relative to the root directory
SETTINGS_FILE="$ROOT_DIR/settings.yaml"
TESTS_DIR="$ROOT_DIR/Tests"
BINARIES_DIR="$ROOT_DIR/Binaries"
CROCO_DIR_RELATIVE="../../croco"  # Relative path for croco, adjusted from absolute path
CROCO_DIR=$(realpath "$ROOT_DIR/$CROCO_DIR_RELATIVE")  # Resolve relative path to absolute

CPPDEFS_FILE="$CROCO_DIR/OCEAN/cppdefs.h"
BIO_NCHL_FILE="$CROCO_DIR/OCEAN/bio_NChlPZD.F"
T3DMIX_FILE="$CROCO_DIR/OCEAN/t3dmix_S.F"
COMPILE_SCRIPT="$ROOT_DIR/jobcomp"

FORCE_REINIT=false

# Parse the -F flag
if [[ "$1" == "-F" ]]; then
    FORCE_REINIT=true
    echo "Force reinitialization enabled. Existing settings and directories will be overwritten."
fi

# Check if settings.yaml exists
if [[ -f "$SETTINGS_FILE" && "$FORCE_REINIT" == false ]]; then
    echo "settings.yaml already exists. Use -F flag to force reinitialization."
    exit 0
fi

#Confirm all the settings before proceeding. Ask for confirmation using Y or N
echo "ROOT_DIR: '$ROOT_DIR'"
echo "TESTS_DIR: '$TESTS_DIR'"
echo "BINARIES_DIR: '$BINARIES_DIR'"
echo "CROCO_DIR: '$CROCO_DIR'"
echo "CPPDEFS_FILE: '$CPPDEFS_FILE'"
echo "BIO_NCHL_FILE: '$BIO_NCHL_FILE'"
echo "T3DMIX_FILE: '$T3DMIX_FILE'"
echo "COMPILE_SCRIPT: '$COMPILE_SCRIPT'"

read -p "Do you want to proceed with the above settings? (Y/N): " CONFIRM
if [[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]]; then
    echo "Initialization cancelled."
    exit 0
fi


# Create or overwrite settings.yaml

echo "Creating settings.yaml..."
cat > "$SETTINGS_FILE" <<EOL
# Project Settings
project:
  root_dir: "$ROOT_DIR"
  tests_dir: "Tests"
  binaries_dir: "Binaries"
  croco_dir: "$CROCO_DIR"  # Full path for croco

# Dependency Tracking
dependencies:
  files:
    - location: "root_dir"
      path: "cppdefs.h"  # This file is relative to root_dir
    - location: "croco_dir"
      path: "OCEAN/bio_NChlPZD.F"  # This file is relative to croco_dir
    - location: "croco_dir"
      path: "OCEAN/t3dmix_S.F"  # This file is relative to croco_dir

# Metadata Options
metadata:
  enable_tracking: true
  track_parameters: true

# Scripts
scripts:
  compile: "./jobcomp"
  browse_tests: "./browse_tests.py"
EOL
echo "settings.yaml created or overwritten."

# Create directory structure
if [[ "$FORCE_REINIT" == true ]]; then
    echo "Removing existing directories..."
    rm -rf "$TESTS_DIR" "$BINARIES_DIR"
fi

mkdir -p "$TESTS_DIR" "$BINARIES_DIR"
echo "Project initialized. Tests and Binaries directories created."

# If the jobcomp script doesn't exist, give an error message
if [[ ! -f "$COMPILE_SCRIPT" || ! -x "$COMPILE_SCRIPT" ]]; then
    echo "Error: Compilation script '$COMPILE_SCRIPT' not found or not executable. Please check the path."
    exit 1
fi