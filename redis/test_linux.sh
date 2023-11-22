#!/bin/bash

testVersion() {
  assertEquals "redis-cli 7.2.3" "$(../bin/redis-cli --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
