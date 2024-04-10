#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.7.3 - libarchive 3.7.3 zlib/1.3.1 liblzma/5.4.5 libzstd/1.5.6 " "$(../bin/bsdtar --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
