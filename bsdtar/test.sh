#!/bin/bash
dp0="$(realpath "$(dirname "$0")")" && cd "$dp0" || exit 1

testEquality() {
  assertEquals 1 1
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
