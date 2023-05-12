#!/bin/bash

alpine_version="3.18.0"
self_name="ansible-alpine-$alpine_version"
image_name="$self_name:latest"

docker load --input "../bin/$self_name.tar.gz"

test_version() {
  assertEquals "ansible [core 2.13.6]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.10 (main, Feb  9 2023, 02:08:14) [GCC 12.2.1 20220924]
  jinja version = 3.1.2
  libyaml = True" "$(docker run --rm $image_name ansible --version)"
}

test_ansible_lint_version() {
  assertEquals "ansible-lint 6.9.1 using ansible 2.13.6" "$(docker run --rm $image_name ansible-lint --version | head -1)"
}

test_ansible_galaxy_version() {
  assertEquals "ansible-galaxy [core 2.13.6]" "$(docker run --rm $image_name ansible-galaxy --version | head -1)"
}

# Load and run shUnit2.
source "../.tests/shunit2/shunit2"
