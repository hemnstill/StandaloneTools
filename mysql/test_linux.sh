#!/bin/bash

testVersion() {
  assertEquals "../bin/mysql  Ver 8.1.0 for Win64 on x86_64 (Source distribution)" "$(../bin/mysql --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
