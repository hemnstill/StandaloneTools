#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.7.5 - libarchive 3.7.5 zlib/1.3.1 liblzma/5.6.2 libzstd/1.5.6 " "$(../bin/bsdtar --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
