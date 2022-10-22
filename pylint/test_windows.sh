#!/bin/bash

test_version() {
  assertEquals "pylint 2.15.3
astroid 2.12.12
Python 3.10.5 (main, Jun 27 2022, 04:54:25) [MSC v.1929 64 bit (AMD64)]" "$(../bin/pylint.bat --version | dos2unix )"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
