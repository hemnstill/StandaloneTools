#!/bin/bash

testVersion() {
  assertEquals "OpenSSL 3.1.1 30 May 2023 (Library: OpenSSL 3.1.1 30 May 2023)" "$(../bin/openssl.exe version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
