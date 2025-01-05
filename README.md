# Scripting Project Overview

This project consists of several Bash scripts designed to manage and organize a testing environment for a project. The scripts help in creating, navigating, and managing tests, as well as initializing the project structure. Below is an overview of each script and its functionality.

## Scripts and Features

### `tree.sh`

**Overview:**  
This script displays a tree structure of all tests and their subtests, showing dependencies between tests.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Tests Directory Extraction:** Extracts the `tests_dir` value from `settings.yaml` using `yq`.
- **Test Tree Display:** Recursively lists all subtests and displays them in a tree format.
- **Dependency Tracking:** Shows dependencies between tests as specified in `metadata.yaml`.

---

### `add_branch.sh`

**Overview:**  
This script adds a branch (subtest) to the current test folder.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Branch Creation:** Creates a new branch test inside the current test directory.
- **Metadata Update:** Updates the `metadata.yaml` file for the new branch test to reflect its parent test and name.
- **Directory Structure:** Copies necessary files from the parent test to the new branch test and creates a `subtests` directory within the new branch.

---

### `add_test.sh`

**Overview:**  
This script creates a new base test with the specified name and initializes its directory structure.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Test Creation:** Prompts the user for a test name and creates a new test directory.
- **Dependency Management:** Extracts and copies dependencies specified in `settings.yaml` to the test directory.
- **Metadata Creation:** Generates a `metadata.yaml` file for the new test, including test name, binary path, and dependencies.
- **Dummy Binary Creation:** Creates a dummy binary for testing purposes if the compilation script is not found.

---

### `goto.sh`

**Overview:**  
This script navigates to the directory of a specified test.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Test Directory Navigation:** Navigates to the directory of the specified test.
- **Multiple Matches Handling:** If multiple tests with the same name exist, prompts the user to choose which one to navigate to.
- **Root Test Directory Navigation:** If no test name is provided, navigates to the root test directory.

---

### `initialize_project.sh`

**Overview:**  
This script initializes the project directory structure and creates the necessary configuration files.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Directory Structure Creation:** Creates `Tests` and `Binaries` directories.
- **Settings File Creation:** Generates a `settings.yaml` file with project settings, including paths to dependencies and scripts.
- **Force Reinitialization:** Supports a `-F` flag to force reinitialization, overwriting existing settings and directories.
- **Compilation Script Check:** Verifies the existence and executability of the compilation script.

---

### `remove_test.sh`

**Overview:**  
This script removes a specified test and its subtests, updating any tracking information.

**Features:**
- **Root Directory Detection:** Automatically detects the project root directory by looking for `settings.yaml`.
- **Test Removal:** Removes the specified test and all its subtests.
- **Metadata Update:** Updates the `metadata.yaml` file of the parent test to remove references to the deleted test.
- **Binary Cleanup:** Checks if the binary associated with the test is used by any other test and removes it if not.
- **Subtest Listing:** Lists all subtests before removal and prompts the user for confirmation.

---

## Usage

To use these scripts, ensure that `settings.yaml` is present in the project root directory. The scripts should be sourced or executed with the appropriate arguments as described in their respective overviews.

**Example:**
```bash
source goto.sh test_name
./add_test.sh new_test_name