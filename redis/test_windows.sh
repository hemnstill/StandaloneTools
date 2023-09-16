#!/bin/bash

testVersion() {
  assertEquals "redis-cli 7.2.1" "$(../bin/redis-cli.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
