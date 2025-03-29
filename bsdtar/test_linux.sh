#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.7.8 - libarchive 3.7.8 zlib/1.3.1 liblzma/5.4.5 libzstd/1.5.7 " "$(../bin/bsdtar --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
