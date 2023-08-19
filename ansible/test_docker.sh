#!/bin/bash

alpine_version="3.18.3"
self_name="ansible-alpine-$alpine_version"
image_name="$self_name:latest"

docker load --input "../bin/$self_name.tar.gz"

test_version() {
  assertEquals "ansible [core 2.14.5]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.11/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.11.4 (main, Jun  9 2023, 02:29:05) [GCC 12.2.1 20220924] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True" "$(docker run --rm $image_name ansible --version)"
}

test_ansible_galaxy_version() {
  assertEquals "ansible-galaxy [core 2.14.5]" "$(docker run --rm $image_name ansible-galaxy --version | head -1)"
}

test_ansible_lint_version() {
  assertEquals "ansible-lint 6.17.2 using ansible-core:2.14.5 ansible-compat:4.0.4 ruamel-yaml:0.17.28 ruamel-yaml-clib:0.2.7" "$(docker run --rm $image_name ansible-lint --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
