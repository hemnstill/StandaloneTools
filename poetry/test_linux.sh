#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true
is_ubuntu_os=false && [[ -f "/etc/lsb-release" ]] && is_ubuntu_os=true

if [[ "$is_alpine_os" == true ]]; then
  apk update
  apk add --no-cache mariadb-connector-c-dev
fi

if [[ $is_ubuntu_os == true ]]; then
  apt update
  apt install -y clang libmysqlclient-dev
fi

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
mysqlclient = "2.1.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
'

poetry_install_stdout='Updating dependencies
Resolving dependencies...

Package operations: 6 installs, 0 updates, 0 removals

  • Installing certifi (2023.5.7)
  • Installing charset-normalizer (3.1.0)
  • Installing idna (3.4)
  • Installing urllib3 (1.26.16)
  • Installing mysqlclient (2.1.1)
  • Installing requests (2.28.2)

Writing lock file'

test_version() {
  assertEquals "Poetry (version 1.5.0)" "$(../bin/poetry.sh --version)"
}

test_install_from_symlink() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  ln -sf "$(readlink -f ../bin/poetry.sh)" /usr/local/bin/poetry

  assertEquals "$poetry_install_stdout" "$(poetry install)"
}

test_install_from_sh() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  assertEquals "Installing dependencies from lock file

No dependencies to install or update" "$(../bin/poetry.sh install)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
