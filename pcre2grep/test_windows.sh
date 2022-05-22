#!/bin/bash

grep="../bin/pcre2grep.exe"

testVersion() {
  assertEquals "pcre2grep version 10.40 2022-04-14" "$("$grep" --version)"
}

testDoubleQuotes() {
   assertEquals "test-quotes.zip" "$(echo "test-quotes.zip" | "$grep" --only-matching "[^"" ]*quotes\.zip")"
}

testUtf8Smile() {
  assertEquals "test-utf8-😃.zip" "$(echo "test-utf8-😃.zip" | "$grep" "utf8-😃\.zip")"
}

testLC_ALL() {
  export LC_ALL=en_US.UTF-8
  assertEquals "test-locale.zip" "$(echo "test-locale.zip" | "$grep" "locale\.zip")"
}


# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
