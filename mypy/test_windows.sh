#!/bin/bash

test_version() {
  assertEquals "mypy 1.1.1 (compiled: yes)" "$(../bin/mypy.bat --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
