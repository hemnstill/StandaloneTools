#!/bin/bash

test_version() {
  assertEquals "Poetry (version 1.4.2)" "$(../bin/poetry.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
