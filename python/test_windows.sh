#!/bin/bash

test_version() {
  assertEquals "Python 3.13.1" "$(../bin/Scripts/python.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
