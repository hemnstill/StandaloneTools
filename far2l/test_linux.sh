#!/bin/bash

test_version() {
  assertEquals "FAR2L Version: 2.6.4-beta" "$(../bin/far2l --help | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
