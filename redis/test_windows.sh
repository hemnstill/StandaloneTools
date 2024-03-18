#!/bin/bash

testVersion() {
  assertEquals "redis-cli 7.2.3" "$(../bin/redis-cli.exe --version | head -c 15)"
}

testServerVersion() {
  assertEquals "Redis server v=7.2.3" "$(../bin/redis-server.exe --version | head -c 20)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
