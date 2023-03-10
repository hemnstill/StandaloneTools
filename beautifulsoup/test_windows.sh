#!/bin/bash

test_version() {
  assertEquals "4.11.2" "$(../bin/Scripts/python.exe -c "import bs4; print(bs4.__version__)")"
}

test_lxml_version() {
  assertEquals "4.9.2" "$(../bin/Scripts/python.exe -c "import lxml; print(lxml.__version__)")"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
