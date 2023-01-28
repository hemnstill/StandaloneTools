#!/bin/bash

testVersion() {
  assertEquals "upx 3.96" "$(../bin/upx --version | head -1)"
}

testPackedVersion() {
  assertEquals "upx 3.96" "$(../bin/upx_packed --version | head -1)"
}

testPackedBsdtarVersion() {
  assertEquals "bsdtar 3.6.2 - libarchive 3.6.2 zlib/1.2.12 liblzma/5.2.5 libzstd/1.5.2 " "$(../bin/bsdtar --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
