#!/bin/bash

grep="../bin/pcre2grep.exe"

testVersion() {
  assertEquals "pcre2grep version 10.40 2022-04-14" "$("$grep" --version)"
}

testDoubleQuotes() {
   assertEquals "test-win64.zip" "$(echo "test-win64.zip" | "$grep" --only-matching "[^"" ]*win64\.zip")"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
