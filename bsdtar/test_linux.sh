#!/bin/bash

testVersion() {
  assertEquals "bsdtar 3.8.1 - libarchive 3.8.1 zlib/1.3.1 liblzma/5.6.3 libzstd/1.5.7 openssl/3.5.1 libb2/bundled " "$(../bin/bsdtar --version)"
}

testZipEncrypt() {
  assertEquals "" "$(../bin/bsdtar --format zip --options zip:encryption=aes256 --passphrase "pwd" -czvf "test_zip.tar.gz" ../bin/bsdtar)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
