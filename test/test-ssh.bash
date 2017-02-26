#!/bin/bash -u

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
}

function onExit() {
  popd > /dev/null 2>&1
}

function testSsh() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  local result=
  while read -r _line; do
    result=$(../ops -n -F ./ssh_config -n ssh "${_line}" 'uname -n')
    if [[ $?  != 0 ]]; then
      error "ERROR - ${_line}"
    elif [ "${result}" != "${_line}" ]; then
      echo -e "NG - ${_line} <-> ${result}"
    else
      echo -e "OK - ${_line}"
    fi
  done <<-'END'
w01
END
}

setup
testSsh
