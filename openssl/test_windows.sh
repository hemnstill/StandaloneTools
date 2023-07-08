#!/bin/bash

testVersion() {
  assertEquals "OpenSSL 1.1.1m" "$(../bin/openssl.exe version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
