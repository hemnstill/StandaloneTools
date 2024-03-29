#!/bin/bash

is_alpine_os=false && [[ -f "/etc/alpine-release" ]] && is_alpine_os=true

if [[ "$is_alpine_os" == true ]]; then
  apk update
  apk add --no-cache gcompat

  { printf '%s' "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m
y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu
tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp
m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY
KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc
Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m
1QIDAQAB
-----END PUBLIC KEY-----"
} > "/etc/apk/keys/sgerrand.rsa.pub"
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.24-r0/glibc-2.24-r0.apk
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.24-r0/glibc-bin-2.24-r0.apk
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.24-r0/glibc-i18n-2.24-r0.apk
  apk add --force-overwrite glibc-2.24-r0.apk glibc-bin-2.24-r0.apk glibc-i18n-2.24-r0.apk
  /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
  export LC_ALL=en_US.UTF-8
fi
