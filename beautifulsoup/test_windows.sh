#!/bin/bash

test_version() {
  assertEquals "beautifulsoup4 4.11.2" "$(../bin/pylint.bat --version | dos2unix )"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
