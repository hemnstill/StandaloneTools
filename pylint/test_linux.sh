#!/bin/bash

../.tools/install_alpine_glibc.sh

test_version() {
  assertEquals "pylint 3.0.3
astroid 2.15.5
Python 3.11.3 (main, May  7 2023, 19:33:53) [Clang 16.0.3 ]" "$(../bin/pylint.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
