#!/bin/bash

grep="../bin/pcre2grep"

testVersion() {
  assertEquals "pcre2grep version 10.49 2026-09-28" "$("$grep" --version)"
}

testDoubleQuotesWithSpaces() {
  assertEquals "test-quotes.zip" "$(echo "test-quotes.zip" | "$grep" --only-matching "[^"" ]*quotes\.zip")"
}

testParenthesesBracesEscapeDoubleQuotes() {
  assertEquals "a1" "$(printf ' "sha": "a1",' | "$grep" --only-matching "(?<=\"sha\":\s\")[^,]+(?=\")")"
}

testParenthesesBracesSingleQuotes() {
  assertEquals "a1" "$(printf ' "sha": "a1",' | "$grep" --only-matching '(?<="sha":\s")[^,]+(?=")')"
}

testUtf8Smile() {
  assertEquals "test-utf8-😃.zip" "$(echo "test-utf8-😃.zip" | "$grep" "utf8-😃\.zip")"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
