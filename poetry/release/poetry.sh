#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
"$dp0/Scripts/python" "%~dp0__main__.py" %*
