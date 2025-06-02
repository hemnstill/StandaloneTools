#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.8.0 - libarchive 3.8.0 zlib/1.3.1 liblzma/5.6.3 libzstd/1.5.7 " "$(../bin/bsdtar --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
