#!/bin/bash

../.tools/install_alpine_glibc.sh

test_version() {
  assertEquals "Python 3.11.3" "$(../bin/Scripts/bin/python3 --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
