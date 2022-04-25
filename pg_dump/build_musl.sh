#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

echo "::group::install deps"

apk update
apk add --no-cache alpine-sdk zlib-dev zlib-static postgresql-dev

echo "::endgroup::"

tool_name="pg_dump"
tool_version="REL_14_2"
echo "::set-output name=tool_name::$tool_name"
echo "::set-output name=tool_version::$tool_version"

download_url="https://github.com/postgres/postgres/archive/refs/tags/$tool_version.tar.gz"
echo "::group::prepare sources $download_url"

mkdir -p "$dp0/release" && cd "$dp0/release"
wget "$download_url" -O "tool-$tool_version.tar.gz"
tar -xf "tool-$tool_version.tar.gz" && cd "tool-$tool_version"

echo "::endgroup::"

echo "::group::build"

./configure
make -j$(nproc)

echo "::endgroup::"
