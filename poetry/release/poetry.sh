#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
"$dp0/Scripts/bin/python3" "%~dp0__main__.py" %*
