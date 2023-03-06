#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true

test_version() {
  if [[ "$is_alpine_os" == true ]]; then
    assertEquals "mypy 1.0.1 (compiled: no)" "$(../bin/mypy.sh --version)"
  else
    assertEquals "mypy 1.0.1 (compiled: yes)" "$(../bin/mypy.sh --version)"
  fi
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
