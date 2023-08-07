#!/bin/bash

testVersion() {
  assertEquals "ripunzip 0.4.0" "$(../bin/ripunzip.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
