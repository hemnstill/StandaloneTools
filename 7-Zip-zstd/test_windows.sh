#!/bin/bash

testVersion() {
  assertEquals "7zip" "$(../bin/7z.exe | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
