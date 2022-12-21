#!/bin/bash

test_version() {
  assertEquals "mypy 0.991" "$(../bin/mypy.bat --version | dos2unix )"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
