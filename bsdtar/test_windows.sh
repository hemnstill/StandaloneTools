#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.7.3 - libarchive 3.7.3 zlib/1.2.12 liblzma/5.2.5 libzstd/1.5.2 " "$(../bin/bsdtar.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
