#!/bin/bash

testVersion() {
  assertEquals "upx" "$(../bin/upx.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
