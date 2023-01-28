#!/bin/bash

testVersion() {
  assertEquals "upx 3.96" "$(../bin/upx.exe --version | head -1)"
}

testPackedVersion() {
  assertEquals "upx 3.96" "$(../bin/upx_packed --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
