#!/bin/bash

testVersion() {
  assertEquals "tar (busybox) 1.39.0.git-6354-g5f09fb446" "$(../bin/busybox.exe tar --version | head -1)"

  { printf '```
%s
```

' "$(../bin/busybox.exe)"
  } > ./test-windows.md

}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
