#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
"$dp0/python/install/bin/python3" "$dp0/__main__ansible-config.py" "$@"
