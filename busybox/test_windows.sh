#!/bin/bash

testVersion() {
  assertEquals "tar (busybox) 1.35.0.git" "$(../bin/busybox64.exe tar --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
