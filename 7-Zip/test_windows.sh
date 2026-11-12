#!/bin/bash

testVersion() {
  assertEquals "
7-Zip (z) 26.06 (x64) : Copyright (c) 1999-2026 Igor Pavlov : 2026-11-06" "$(../bin/7zz.exe | dos2unix | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
