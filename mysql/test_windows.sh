#!/bin/bash

testVersion() {
  assertEquals "../bin/mysql.exe  Ver 8.4.3 for Win64 on x86_64 (Source distribution)" "$(../bin/mysql.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
