#!/bin/bash

is_musl_build=false && [[ -f "../build-musl.tar.gz" ]] && is_musl_build=true

test_version() {
  if [[ "$is_musl_build" == true ]]; then
    assertEquals "mypy 1.4.1 (compiled: no)" "$(../bin/mypy.sh --version)"
  else
    assertEquals "mypy 1.4.1 (compiled: yes)" "$(../bin/mypy.sh --version)"
  fi
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
