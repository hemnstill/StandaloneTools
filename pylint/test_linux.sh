#!/bin/bash

test_version() {
  assertEquals "pylint 2.16.4
astroid 2.15.0
Python 3.11.1 (main, Jan 16 2023, 20:56:10) [MSC v.1929 64 bit (AMD64)]" "$(../bin/pylint.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
