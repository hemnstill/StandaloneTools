#!/bin/bash

test_version() {
  assertEquals "Poetry (version 1.5.0)" "$(../bin/poetry.sh --version)"
}

test_install() {
  { printf '
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
  } > pyproject.toml

  assertEquals "Updating dependencies
Resolving dependencies...

Package operations: 5 installs, 0 updates, 0 removals

  • Installing certifi (2023.5.7)
  • Installing charset-normalizer (3.1.0)
  • Installing idna (3.4)
  • Installing urllib3 (1.26.16)
  • Installing requests (2.28.2)

Writing lock file" "$(../bin/poetry.sh install)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
