#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.8.0 - libarchive 3.8.0 zlib/1.3 liblzma/5.6.3 libzstd/1.5.7 cng/1.0 libb2/bundled " "$(../bin/bsdtar.exe --version)"
}

testZipEncrypt() {
  assertEquals "" "$(../bin/bsdtar.exe --format zip --options zip:encryption=aes256 --passphrase "pwd" -czvf "test_zip.tar.gz" ../bin/bsdtar.exe)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
