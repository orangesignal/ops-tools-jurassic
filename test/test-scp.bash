#!/bin/bash -euf

declare -r ops_args='-n -F ./ssh_config'
declare -r ops_limit_arg='-l 1024'

function trace_run() { echo "+ $@"; "$@"; }
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
    ../ops ${ops_args} ssh "${1}" "mkdir ${dest_dir}"
    ../ops ${ops_args} ${ops_limit_arg} scp "$@" || echo "ERROR - ops scp failed"
    ../ops ${ops_args} ssh "${1}" "find ${dest_dir} | sort && rm -rf ${dest_dir}"
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
