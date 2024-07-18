#!/bin/bash

testVersion() {
  assertEquals "
7-Zip (z) 24.07 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-06-19" "$(../bin/7zz.exe | dos2unix | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
