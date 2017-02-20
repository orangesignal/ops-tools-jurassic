#!/bin/bash -u

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
}

function onExit() {
  popd > /dev/null 2>&1
}

function testCommand() {
  while read -r line; do
    local result=$(../ops cmd -F ./ssh_config -q "${line}" 'uname -n')
    if [[ $?  != 0 ]]; then
      error "ERROR - ${line}"
    elif [ "${result}" != "${line}" ]; then
      echo -e "NG - ${line} <-> ${result}"
    else
      echo -e "OK - ${line}"
    fi
  done <<'END'
w01
w01
END
}

setup
testCommand
