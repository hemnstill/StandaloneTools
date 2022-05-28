@echo off
set grep="..\bin\pcre2grep.exe"
echo "sha": "b1", | %grep% --only-matching "(?<=""sha"":\s"")[^,]+(?="")"
