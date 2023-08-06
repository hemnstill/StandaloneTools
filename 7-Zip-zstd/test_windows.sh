#!/bin/bash

testVersion() {
  assertEquals "
7-Zip (z) 23.01 (x64) : Copyright (c) 1999-2023 Igor Pavlov : 2023-06-20" "$(../bin/7z.exe | dos2unix | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
