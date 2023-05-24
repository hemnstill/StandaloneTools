#!/bin/bash
dp0="$(dirname "$(readlink -f "$0")")"
"$dp0/Scripts/bin/python3" "$dp0/__main__poetry.py" "$@"
