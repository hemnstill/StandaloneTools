#!/bin/bash

test_version() {
  assertEquals "pylint 2.15.3
astroid 2.12.12
Python 3.10.5 (main, Jun 27 2022, 04:27:12) [Clang 14.0.3 ] " "$(../bin/pylint.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
