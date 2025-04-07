#!/bin/bash

testVersion() {
  assertEquals "ripunzip 2.0.1" "$(../bin/ripunzip.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
