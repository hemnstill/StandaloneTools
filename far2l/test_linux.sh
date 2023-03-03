#!/bin/bash

test_version() {
  assertEquals "FAR2L - oldschool file manager, with built-in terminal and other usefullness'es" "$(../bin/far2l --help)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
