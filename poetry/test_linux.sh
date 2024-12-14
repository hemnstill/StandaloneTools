#!/bin/bash

is_ubuntu_os=false && [[ -f "/etc/lsb-release" ]] && is_ubuntu_os=true

if [[ $is_ubuntu_os == true ]]; then
  apt update
  apt install -y clang libmysqlclient-dev pkg-config
fi

readme_content='test readme content'

pyproject_content='
[tool.poetry]
name = "StandaloneTools"
version = "1.0.0"
description = ""
authors = []
readme = "README.md"

[tool.poetry.dependencies]
python = "3.12.5"
requests = "2.28.2"
mysqlclient = "2.2.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
'

poetry_install_stdout='Updating dependencies
Resolving dependencies...

Package operations: 6 installs, 0 updates, 0 removals

  - Installing certifi (2024.8.30)
  - Installing charset-normalizer (3.3.2)
  - Installing idna (3.8)
  - Installing urllib3 (1.26.20)
  - Installing mysqlclient (2.2.1)
  - Installing requests (2.28.2)

Writing lock file'

test_version() {
  assertEquals "Poetry (version 1.8.3)" "$(../bin/poetry.sh --version)"
}

test_version_plugins() {
  assertEquals "
  - poetry-plugin-export (1.8.0) Poetry plugin to export the dependencies to various formats
      1 application plugin

      Dependencies
        - poetry (>=1.8.0,<3.0.0)
        - poetry-core (>=1.7.0,<3.0.0)

  - poetry-plugin-sort (0.2.1) Poetry plugin to sort the dependencies alphabetically
      1 application plugin

      Dependencies
        - poetry (>=1.2.0,<2.0.0)" "$(../bin/poetry.sh self show plugins)"
}

test_install_from_symlink() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  { printf '%s' "$readme_content"
  } > README.md

  ln -sf "$(readlink -f ../bin/poetry.sh)" /usr/local/bin/poetry

  assertEquals "$poetry_install_stdout" "$(poetry install --no-root)"
}

test_install_from_sh() {
  { printf '%s' "$pyproject_content"
  } > pyproject.toml

  { printf '%s' "$readme_content"
  } > README.md

  assertEquals "Installing dependencies from lock file

No dependencies to install or update" "$(../bin/poetry.sh install --no-root)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
