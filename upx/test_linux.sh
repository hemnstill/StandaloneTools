#!/bin/bash

testVersion() {
  assertEquals "upx 3.96" "$(../bin/upx --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
