#!/bin/bash

is_windows_os=false && [[ $(uname) == Windows_NT* ]] && is_windows_os=true
is_nanoserver_os=false && $is_windows_os && [[ ! -f "C:\Windows\notepad.exe" ]] && is_nanoserver_os=true

readme_content='test readme content'

pyproject_content='
[tool.poetry]
name = "StandaloneTools"
version = "1.0.0"
description = ""
authors = []
readme = "README.md"

[tool.poetry.dependencies]
python = "3.13.1"
requests = "2.28.2"
mysqlclient = "2.2.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
'

poetry_install_stdout_etalon='Updating dependencies
Resolving dependencies...

Package operations: 1 install, 0 updates, 0 removals
'

test_version() {
  assertEquals "Poetry (version 1.8.5)" "$(../bin/poetry.bat --version)"
}

test_install_from_path() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  { printf '%s' "$readme_content"
  } > README.md

  path_with_poetry="$PATH;$(readlink -f ../bin)"
  export PATH="$path_with_poetry"

  poetry_install_stdout="$(poetry install --no-root | dos2unix)"

  echo "$poetry_install_stdout"

  assertEquals "$(echo "$poetry_install_stdout_etalon" | head -4)" "$(echo "$poetry_install_stdout" | head -4)"
}

test_install_from_bat() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  { printf '%s' "$readme_content"
  } > README.md

  assertEquals "Installing dependencies from lock file

No dependencies to install or update" "$(../bin/poetry.bat install --no-root | dos2unix)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
