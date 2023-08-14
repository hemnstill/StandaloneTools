#!/bin/bash

testVersion() {
  assertEquals "
7-Zip (z) 22.00 ZS v1.5.2 (x64) : Copyright (c) 1999-2022 Igor Pavlov : 2022-06-15" "$(../bin/7zz | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
