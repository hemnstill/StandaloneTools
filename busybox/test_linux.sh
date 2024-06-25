#!/bin/bash

testVersion() {
  assertEquals "tar (busybox) 1.36.1" "$(../bin/busybox tar --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
