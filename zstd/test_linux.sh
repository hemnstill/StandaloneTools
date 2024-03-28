#!/bin/bash

testVersion() {
  assertEquals "*** Zstandard CLI (64-bit) v1.5.6, by Yann Collet ***" "$(../bin/zstd --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
