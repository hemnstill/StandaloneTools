#!/bin/bash

test_version() {
  assertEquals "playwright 1.31.1
Python 3.10.9 (main, Dec 21 2022, 04:01:57) [Clang 14.0.3 ]" "$(../bin/playwright.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
