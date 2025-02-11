# Project Management Scripts

This project provides a suite of bash scripts designed to streamline the creation, management, and execution of tests for a numerical model. These scripts automate common tasks such as initializing the project structure, creating new tests, running tests, and synchronizing configurations between different environments.

## Script Descriptions

*   **`add_branch`**: Creates a new subtest (branch) within an existing test directory, inheriting the parent test's configuration.
*   **`add_diffusion_subtests`**: Adds a set of standard diffusion-related subtests to a given test case.
*   **`add_test`**: Creates a new test case, setting up the directory structure, metadata, and dependencies.
*   **`compile_test`**: Compiles the model binary for a specific test case, managing dependencies and CPU core settings.
*   **`generate_settings`**: Generates the `settings.yaml` file, which configures project-wide settings.
*   **`goto`**: Navigates the user to a specified test directory.
*   **`initialize_project`**: Initializes the project directory structure, creating essential directories and configuration files.
*   **`load_configuration`**: Loads configuration settings for a test case, copying necessary files and updating metadata.
*   **`make_executable`**: Makes all files in the current directory executable.
*   **`remove_test`**: Removes a test case and its associated files.
*   **`run_test`**: Executes a test case, managing parallelization options and logging.
*   **`set_cpu_cores`**: Sets the number of CPU cores to be used for a test, updating the `param.h` file and metadata.
*   **`sync_configs`**: Synchronizes configuration files between different environments (e.g., workstation and HPC).
*   **`sync_project`**: Synchronizes the project directory between different environments.
*   **`sync_symlinks`**: Updates symbolic links within the project to point to the correct locations.
*   **`ttree`**: Displays a tree-like structure of the tests directory, showing test status.

## Workflow

The typical workflow for using these scripts is as follows:

1.  **Initialize the project:**
    *   Run `./initialize_project` to set up the basic directory structure and create the `settings.yaml` file.
2.  **Create a new test:**
    *   Run `./add_test` to create a new test case. The script will prompt you for a description and reason for the test.
    *   The script uses `load_configuration` to copy the relevant configuration files into the test directory.
    *   The script uses `add_diffusion_subtests` to create subtests for different diffusion configurations.
3.  **Configure the test:**
    *   Navigate to the test directory using `source goto <test_id>`.
    *   Modify the input files in the `inputs/` directory as needed.
4.  **Compile the model:**
    *   Run `./compile_test` to compile the model binary. This script manages dependencies and CPU core settings.
5.  **Run the test:**
    *   Run `./run_test` to execute the test. This script provides options for parallelization using OpenMP or MPI.
6.  **Analyze the results:**
    *   Inspect the output files in the `outputs/` directory.
7.  **Manage the project:**
    *   Use `./ttree` to view the test directory structure and test statuses.
    *   Use `./add_branch` to create subtests for different configurations or scenarios.
    *   Use `./remove_test` to remove a test case that is no longer needed.
8.  **Synchronize with remote environments (optional):**
    *   Use `./sync_configs`, `./sync_project`, and `./sync_symlinks` to synchronize the project directory and configuration files between the workstation and the remote Jubail HPC environment.