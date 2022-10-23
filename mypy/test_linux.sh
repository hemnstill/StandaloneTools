#!/bin/bash

test_version() {
  assertEquals "mypy 0.942 (compiled: no)" "$(../bin/mypy.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
