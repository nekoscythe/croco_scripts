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
        echo "$(pwd)"
        exit 1
    fi
}

# Get the root directory
ROOT_DIR=$(get_root_dir)

# Retrieve settings from settings.yaml
SETTINGS_FILE="$ROOT_DIR/settings.yaml"
TESTS_DIR=$(awk '/tests_dir:/ {print $2}' "$SETTINGS_FILE" | xargs)
BINARIES_DIR=$(awk '/binaries_dir:/ {print $2}' "$SETTINGS_FILE" | xargs)

CROCO_DIR_RELATIVE=$(awk '/croco_dir:/ {print $2}' "$SETTINGS_FILE" | xargs)
COMPILE_SCRIPT=$(awk '/compile:/ {print $2}' "$SETTINGS_FILE" | xargs)

# Debug output to check the values
echo "ROOT_DIR: '$ROOT_DIR'"
echo "CROCO_DIR_RELATIVE: '$CROCO_DIR_RELATIVE'"
echo "COMPILE_SCRIPT: '$COMPILE_SCRIPT'"

# Resolve the absolute path for CROCO_DIR
# If the path is absolute, just use it directly, otherwise resolve it relative to ROOT_DIR
if [[ "$CROCO_DIR_RELATIVE" =~ ^/ ]]; then
    CROCO_DIR="$CROCO_DIR_RELATIVE"  # Absolute path, no need to prepend ROOT_DIR
else
    CROCO_DIR="$ROOT_DIR/$CROCO_DIR_RELATIVE"  # Resolve relative to ROOT_DIR
fi

# Verify CROCO_DIR existence
if [[ ! -d "$CROCO_DIR" ]]; then
    echo "Error: CROCO directory '$CROCO_DIR' not found. Check settings.yaml."
    exit 1
fi

# Ensure COMPILE_SCRIPT is relative to the ROOT_DIR
COMPILE_SCRIPT_PATH="$ROOT_DIR/$COMPILE_SCRIPT"
if [[ ! -x "$COMPILE_SCRIPT_PATH" ]]; then
    echo "Warning: Compilation script '$COMPILE_SCRIPT_PATH' not found or not executable. Creating dummy binary."
fi

# Prompt for test name
read -p "Enter the name of the base test: " TEST_NAME
if [[ -z "$TEST_NAME" ]]; then
    echo "Error: Test name cannot be empty."
    exit 1
fi

# Check if the test already exists
if [[ -d "$ROOT_DIR/$TESTS_DIR/$TEST_NAME" ]]; then
    echo "Error: Test '$TEST_NAME' already exists. Please choose a different name."
    exit 1
fi

# Confirm the test creation with all the details
echo ""
echo "Creating a base test with the following details:"
echo "Test name: $TEST_NAME"
echo "Tests directory: $ROOT_DIR/$TESTS_DIR"
echo "Binaries directory: $ROOT_DIR/$BINARIES_DIR"

# Confirm the creation
read -p "Do you want to proceed with the creation of the base test? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Base test creation aborted."
    exit 1
fi



# Use full path for test directory relative to ROOT_DIR
TEST_PATH="$ROOT_DIR/$TESTS_DIR/$TEST_NAME"
mkdir -p "$TEST_PATH"

# Add a folder in the test directory for subtests called "subtests"
mkdir -p "$TEST_PATH/subtests"

# Ensure the binary directory exists relative to ROOT_DIR
mkdir -p "$ROOT_DIR/$BINARIES_DIR"

# Create a dummy binary instead of running the compile script
echo "Creating a dummy binary for testing..."
echo "This is a dummy binary for $TEST_NAME" > "$ROOT_DIR/$BINARIES_DIR/$TEST_NAME"
cp "$ROOT_DIR/$BINARIES_DIR/$TEST_NAME" "$TEST_PATH/"
echo "Dummy binary created and stored in $TEST_PATH."

# Extract the entire dependencies block
dependencies=$(sed -n '/files:/,/^$/p' "$SETTINGS_FILE" | grep -v 'files:' | grep -v '^$' | grep -v '^ *#')
echo "Dependencies block extracted: 
$dependencies"

# Parse dependencies
declare -a dependency_paths
while read -r line; do
  if [[ $line =~ location:\ \"([^\"]*)\" ]]; then
    location=${BASH_REMATCH[1]}
  elif [[ $line =~ path:\ \"([^\"]*)\" ]]; then
    path=${BASH_REMATCH[1]}
    echo "Processing location: $location, path: $path"
    case $location in
      "root_dir")
        dependency_paths+=("$ROOT_DIR/$path")
        ;;
      "croco_dir")
        dependency_paths+=("$CROCO_DIR_RELATIVE/$path")
        ;;
    esac
  fi
done <<< "$dependencies"

# Print dependencies
echo "Resolved dependency paths:"
for dep in "${dependency_paths[@]}"; do
  echo "$dep"
done

# Copy dependencies to the binaries directory
DEPENDENCIES_DIR="$TEST_PATH/Dependencies"
mkdir -p "$DEPENDENCIES_DIR"
for dep in "${dependency_paths[@]}"; do
  echo "Copying dependency: $dep"
  cp "$dep" "$DEPENDENCIES_DIR/"
done

echo "Dependencies copied successfully."

# Create metadata
cat > "$TEST_PATH/metadata.yaml" <<EOL
test_name: $TEST_NAME
binary_path: $ROOT_DIR/$BINARIES_DIR/$TEST_NAME
dependencies:
EOL

# Add dependencies to the metadata
for dep in "${dependency_paths[@]}"; do
    echo "  - $dep" >> "$TEST_PATH/metadata.yaml"
done

# Add parent test (null in this case since this is a base test)
echo "parent_test: null" >> "$TEST_PATH/metadata.yaml"

echo "Base test $TEST_NAME created with dependencies tracked."
