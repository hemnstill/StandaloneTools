#!/bin/bash

test_version() {
  assertEquals "mypy 0.982 (compiled: yes)" "$(../bin/mypy.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
