#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

alpine_version="3.17.2"
self_name="ansible-alpine-$alpine_version"
image_name="$self_name:latest"

release_version_dirpath="$dp0/release/build"
mkdir -p "$release_version_dirpath"

full_archive_path="$release_version_dirpath/$self_name.tar.gz"

echo "generating Dockerfile ..."
{ printf 'FROM alpine:%s
RUN apk add --no-cache git ansible ansible-lint
' "$alpine_version"
} > "$dp0/Dockerfile"

echo "building image '$image_name' ..."
docker build -t "$image_name" "$dp0/."

echo "saving image '$image_name' to '$full_archive_path'"
docker image save "$image_name" | gzip > "$full_archive_path"

cd "$release_version_dirpath"

{ printf '### build-docker.tar.gz
docker image: %s
%s

%s

%s

' "$image_name" \
  "$(docker run --rm "$image_name" ansible --version)" \
  "$(docker run --rm "$image_name" ansible-lint --version)" \
  "$(docker run --rm "$image_name" ansible-galaxy --version)"
} > build-docker.md

cat build-docker.md

tar -czvf ../build-docker.tar.gz .
