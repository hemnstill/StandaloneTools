#!/bin/bash

testVersion() {
  assertEquals "
7-Zip (z) 23.01 ZS v1.5.5 R3 (x64) : Copyright (c) 1999-2023 Igor Pavlov, 2016-2023 Tino Reichardt : 2023-06-29" "$(../bin/7zz.exe | dos2unix | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
