#!/bin/bash

testVersion() {
  assertEquals "ruff 0.12.7" "$(../bin/ruff --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
