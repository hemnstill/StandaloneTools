#!/bin/bash

pyproject_content='
[tool.poetry]
name = "StandaloneTools"
version = "1.0.0"
description = ""
authors = []
readme = "README.md"

[tool.poetry.dependencies]
python = "3.11.3"
requests = "2.28.2"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
'

poetry_install_stdout='Updating dependencies
Resolving dependencies...

Package operations: 5 installs, 0 updates, 0 removals

  • Installing certifi (2023.5.7)
  • Installing charset-normalizer (3.1.0)
  • Installing idna (3.4)
  • Installing urllib3 (1.26.16)
  • Installing requests (2.28.2)

Writing lock file'

test_version() {
  assertEquals "Poetry (version 1.5.0)" "$(../bin/poetry.bat --version)"
}

test_install_from_path() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  path_with_poetry="$PATH;$(readlink -f ../bin)"
  export PATH="$path_with_poetry"

  assertEquals "$poetry_install_stdout" "$(poetry install --no-ansi | dos2unix | sed "s/\�/\•/g")"
}

test_install_from_bat() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  assertEquals "Installing dependencies from lock file

No dependencies to install or update" "$(../bin/poetry.bat install | dos2unix)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
