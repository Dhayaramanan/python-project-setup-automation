#!/usr/bin/env bash

# default name of the application
project_name="myapp"

# symbols
tick="✓"
cross="✗"


checked_mkdir(){
    echo "[+] Creating directory '${1}'"

    if mkdir "${1}" 2>/dev/null; then
        tput setaf 2; echo "[${tick}] Successfully created directory '${1}'"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to create directory '${1}'"; tput sgr0
    fi
}


checked_touch(){
    echo "[+] Creating file '${1}'"

    if touch "${1}"; then
        tput setaf 2; echo "[${tick}] Successfully created file '${1}'"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to create file '${1}'"; tput sgr0
    fi
}


create_mandatory_directories(){
    if [ -d "${project_name}" ]; then
        tput setaf 1; echo "[${cross}] Project '${project_name}' already exists."; tput sgr0
        exit 1
    fi
    checked_mkdir "${project_name}"

    echo -e "\n========== Creating Mandatory Directories =========="
    checked_mkdir "${project_name}/src"
    checked_mkdir "${project_name}/tests"
}


create_mandatory_files(){
    echo -e "\n========== Creating Mandatory Files =========="
    checked_touch "${project_name}/README.md"
    echo "# ${project_name}
A brief Description of what your project does.

## Installation
\`\`\`bash
pip install -r requirements.txt

## Usage
python src/main.py" > "${project_name}/README.md"

    checked_touch "${project_name}/requirements.txt"

    checked_touch "${project_name}/.gitignore"
    echo "# Byte-compiled files
__pycache__/
*.py[cod]

.gitignore

# Virtual environments
venv/

# Environment variable
.env
${project_name}_env/

# Editor setting
.vscode/" > "${project_name}/.gitignore"

    checked_touch "${project_name}/src/main.py"
    echo "def main():
    print('Welcome to ${project_name}!')

if __name__ == '__main__':
    main()" > "${project_name}/src/main.py"

    checked_touch "${project_name}/tests/test_main.py"
    echo "import unittest
from src.main import main

class TestMain(unittest.TestCase):
    def test_main(self):
        # check if the function runs without errors.
        self.assertIsNone(main())

if __name__ == '__main__':
    unittest.main()" > "${project_name}/tests/test_main.py"


    checked_touch "${project_name}/.env"
    
    checked_touch "${project_name}/pyproject.toml"
    echo "[tool.poetry]
name = "${project_name}"
version = \"0.1.0\"
description = \"A Python project.\"
authors = [\"Your Name <your.email@example.com>\"]

[build-system]
requires = [\"setuptools>=42\", \"wheel\"]
build-backend = \"setuptools.build_meta\"" > "${project_name}/pyproject.toml"
}


check_and_install(){

    echo "[+] Checking for '${1}'"
    if ! command -v "${1}" &> /dev/null; then
        tput setaf 1; echo "[${cross}] ${1} not found"; tput sgr0
        echo "[+] Installing ${1}"

        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y ${1}
        elif command -v yum &> /dev/null; then
            sudo yum install -y ${1}
        else
            tput setaf 1; echo "[${cross}] Unsupported package manager"; tput sgr0
        fi
    else
        tput setaf 2; echo "[${tick}] ${1} already installed"; tput sgr0
    fi
}


create_venv(){
    echo "[+] Creating virtual environment"
    if python3 -m venv "${1}"; then
        tput setaf 2; echo "[${tick}] Successfully created virtual environment"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to create virtual environment"; tput sgr0
    fi
}

activate_venv(){
    echo "[+] Activating virtual environment"

    if [ -d "${1}/bin" ]; then
        source "${1}/bin/activate"
    else
        tput setaf 1; echo "[${cross}] Virtual environment not found"; tput sgr0
    fi

    if [ ! -z "${VIRTUAL_ENV}" ]; then
        tput setaf 2; echo "[${tick}] Successfully activated virtual environment"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to activate virtual environment"; tput sgr0
    fi
}

venv_setup(){
    echo -e "\n========== Checking for necessary tools =========="
    check_and_install "python3"
    check_and_install "pip"
    check_and_install "git"

    env_name="${project_name}_env"

    echo -e "\n========== Creating and activating virtual environment =========="
    create_venv "${project_name}/${env_name}"
    activate_venv "${project_name}/${env_name}"
}


git_initialization(){
    echo -e "\n========== Initializing Git Repository =========="

    echo "[+] Intializing git repository"
    if git init "${project_name}" &> /dev/null; then
        tput setaf 2; echo "[${tick}] Successfully initialized repository"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to initialize repository"; tput sgr0
    fi

    echo "[+] Staging files"
    if git -C "${project_name}" add .; then
        tput setaf 2; echo "[${tick}] Successfully staged files"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to stage files"; tput sgr0
    fi

    echo "[+] Committing files"
    if git -C "${project_name}" commit -m "Initial Project Setup" &> /dev/null; then
        tput setaf 2; echo "[${tick}] Successfully committed"; tput sgr0
    else
        tput setaf 1; echo "[${cross}] Failed to Commit"; tput sgr0
    fi
}


main(){
    if [ $# -eq 1 ]; then
        project_name="${1}"
        if [[ "$project_name" =~ [^a-zA-Z0-9_-] ]]; then
            tput setaf 1; echo "[${cross}] Invalid project name"; tput sgr0
            exit 1
        fi
    elif [ $# -gt 1 ]; then
        echo "Usage: ${0} <project_name>"
        exit 1
    fi


    create_mandatory_directories
    create_mandatory_files
    venv_setup
    git_initialization
}

main "$@"

