#!/bin/bash

testVersion() {
  assertEquals "ruff 0.0.280" "$(../bin/ruff --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
