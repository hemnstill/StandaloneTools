#!/bin/bash

testVersion() {
  assertEquals "ruff 0.11.2" "$(../bin/ruff.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
