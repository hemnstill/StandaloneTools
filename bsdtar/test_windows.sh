#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.7.8 - libarchive 3.7.8 zlib/1.3 liblzma/5.4.4 libzstd/1.5.6 " "$(../bin/bsdtar.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
