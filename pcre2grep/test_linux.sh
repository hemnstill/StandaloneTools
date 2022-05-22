#!/bin/bash

testVersion() {
  assertEquals "pcre2grep version 10.40 2022-04-14" "$(../bin/pcre2grep --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
