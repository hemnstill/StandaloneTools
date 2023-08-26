#!/bin/bash

testVersion() {
  assertEquals "../bin/mysql  Ver 8.1.0 for for Linux on x86_64 (Source distribution)" "$(../bin/mysql --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
