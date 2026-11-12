#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.8.11 - libarchive 3.8.11 zlib/1.4 liblzma/5.8.4 libzstd/1.5.7 openssl/3.5.9 libb2/bundled " "$(../bin/bsdtar --version)"
}

testZipEncrypt() {
  assertEquals "" "$(../bin/bsdtar --format zip --options zip:encryption=aes256 --passphrase "pwd" -czvf "test_zip.tar.gz" ../bin/bsdtar)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
