#!/bin/bash

test_version() {
  assertEquals "pylint 3.0.3
astroid 2.15.5
Python 3.11.3 (main, May  7 2023, 18:40:36) [MSC v.1929 64 bit (AMD64)]" "$(../bin/pylint.bat --version | dos2unix )"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
