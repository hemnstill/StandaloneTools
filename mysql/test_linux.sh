#!/bin/bash

../.tools/install_alpine_glibc.sh

ldd ../bin/mysql

testVersion() {
  assertEquals "../bin/mysql  Ver 8.0.33 for Linux on x86_64 (Source distribution)" "$(../bin/mysql --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
