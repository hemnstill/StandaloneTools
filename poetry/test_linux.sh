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

  assertEquals "Poetry (version 1.5.0)" "$(../bin/poetry.sh install)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
