#!/bin/bash

../.tools/install_alpine_glibc.sh

test_version() {
  assertEquals "pylint 2.16.4
astroid 2.15.0
Python 3.11.1 (main, Jan 16 2023, 22:40:32) [Clang 15.0.7 ]" "$(../bin/pylint.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
