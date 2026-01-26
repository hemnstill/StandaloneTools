#!/bin/bash

"../.tools/install_alpine_glibc.sh"

testVersion() {
  assertEquals "../bin/mysql  Ver 8.4.8 for Linux on x86_64 (Source distribution)" "$(../bin/mysql --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
