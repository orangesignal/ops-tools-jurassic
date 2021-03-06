#!/bin/bash -euf

declare -r ops_args='-n -F ./ssh_config'
declare -r ops_limit_arg='-l 1024'

function trace_run() { echo "+ $@"; "$@"; }
function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
  dest_dir="$(pwd)/test-fetch-$(date +%Y%m%d%H%M%S)"
  mkdir -p "${dest_dir}"
}

function onExit() {
  rm -rf "${dest_dir}"
  popd > /dev/null 2>&1
}

function testFetch() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local line=
  while read -r line; do
    echo "case: $line"
    set -- ${line}
    ../ops ${ops_args} ${ops_limit_arg} fetch "$@"
  done <<-END
w01 /etc/*.conf     ${dest_dir}/conf
w01 /var/spool/cron ${dest_dir}
w01 /etc/init.d/    ${dest_dir}/init.d/
w01 /var/log/syslog ${dest_dir}
w01 /var/log/syslog ${dest_dir}/renamed-syslog
END

  find "${dest_dir}"
}

setup
testFetch
