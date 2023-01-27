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
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-bin-2.35-r0.apk
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-i18n-2.35-r0.apk
  apk add --force-overwrite glibc-2.35-r0.apk glibc-bin-2.35-r0.apk glibc-i18n-2.35-r0.apk
  /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
  export LC_ALL=en_US.UTF-8
fi

test_version() {
  assertEquals "ansible [core 2.14.1]
  config file = None
  configured module search path = ['/github/home/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /__w/StandaloneTools/StandaloneTools/bin/Scripts/lib/python3.11/site-packages/ansible
  ansible collection location = /github/home/.ansible/collections:/usr/share/ansible/collections
  executable location = /__w/StandaloneTools/StandaloneTools/bin/__main__ansible.py
  python version = 3.11.1 (main, Jan 16 2023, 22:40:32) [Clang 15.0.7 ] (/__w/StandaloneTools/StandaloneTools/bin/Scripts/bin/python3)
  jinja version = 3.1.2
  libyaml = True" "$(../bin/ansible.sh --version)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
