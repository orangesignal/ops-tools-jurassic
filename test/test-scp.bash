#!/bin/bash -euf

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
  src_dir="$(pwd)/test-copy-$(date +%Y%m%d%H%M%S)"
  dest_dir="/var/tmp/foobar"
  mkdir -p "${src_dir}"
  echo 'foo text' > "${src_dir}/foo.txt"
  echo 'foo html' > "${src_dir}/foo.html"
  echo 'bar text' > "${src_dir}/bar.txt"
  echo 'bar html' > "${src_dir}/bar.html"
  mkdir "${src_dir}/baz"
  echo 'baz text' > "${src_dir}/baz/baz.txt"
  echo 'baz html' > "${src_dir}/baz/baz.html"
}

function onExit() {
  rm -rf "${src_dir}"
  popd > /dev/null 2>&1
}

function testSsh() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  local result=
  while read -r _line; do
    echo "case: $_line"
    set -- ${_line}
    ../ops -F ./ssh_config -n ssh "${1}" "mkdir ${dest_dir}"
    ../ops -F ./ssh_config -n -l 1024 scp "$@" || echo "ERROR - ops scp failed"
    ../ops -F ./ssh_config -n ssh "${1}" "find ${dest_dir} | sort && rm -rf ${dest_dir}"
  done <<-END
w01 ${src_dir}/foo.txt %u@%h:${dest_dir}
w01 ${src_dir}/foo.txt %u@%h:${dest_dir}/renamed-foo.txt
w01 ${src_dir}         %u@%h:${dest_dir}
w01 ${src_dir}/        %u@%h:${dest_dir}/
w01 ${src_dir}/*.txt   %u@%h:${dest_dir}
END
}

setup
testSsh
