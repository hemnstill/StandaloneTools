#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
export PLAYWRIGHT_BROWSERS_PATH="$dp0/ms-playwright"
"$dp0/Scripts/bin/python3" "$dp0/__main__playwright.py" "$@"

