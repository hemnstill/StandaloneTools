#!/bin/bash

testVersion() {
  assertEquals "tar (busybox) 1.37.0.git-5398-g89ae34445" "$(../bin/busybox.exe tar --version | head -1)"

  "../bin/busybox.exe" > ./test-windows.md
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
