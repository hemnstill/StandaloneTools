#!/bin/bash

test_version() {
  assertEquals "pylint 2.16.4
astroid 2.12.13
Python 3.10.9 (main, Dec 21 2022, 04:16:31) [MSC v.1929 64 bit (AMD64)]" "$(../bin/pylint.bat --version | dos2unix )"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
