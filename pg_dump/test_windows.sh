#!/bin/bash

test_pg_dump_Version() {
  assertEquals "pg_dump (PostgreSQL) 14.4" "$(../bin/pg_dump.exe --version)"
}

test_pg_dump_all_Version() {
  assertEquals "pg_dumpall (PostgreSQL) 14.4" "$(../bin/pg_dumpall.exe --version)"
}

test_pg_restore_Version() {
  assertEquals "pg_restore (PostgreSQL) 14.4" "$(../bin/pg_restore.exe --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
