#!/bin/bash

test_version() {
  assertEquals "Poetry (version 1.3.1)" "$(../bin/ansible.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
