#!/bin/bash

testVersion() {
  assertEquals "
p7zip-zstd (z) 17.05 (x64) : Copyright (c) 1999-2023 Igor Pavlov : 2023-06-20" "$(../bin/7zz | head -2)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
