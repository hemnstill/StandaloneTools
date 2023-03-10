#!/bin/bash

../.tools/install_alpine_glibc.sh

test_version() {
  assertEquals "beautifulsoup 4.11.2" "$(../bin/pylint.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
