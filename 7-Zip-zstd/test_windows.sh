#!/bin/bash

testVersion() {
  assertEquals "
7-Zip 22.01 ZS v1.5.5 R3 (x64) : Copyright (c) 1999-2022 Igor Pavlov, 2016-2023 Tino Reichardt : 2023-06-18" "$(../bin/7z.exe | dos2unix | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
