#!/bin/bash -u

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
}

function onExit() {
  popd > /dev/null 2>&1
}

function testCommand() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  local _result=
  while read -r _line; do
    _result=$(../ops -n -F ./ssh_config cmd "${_line}" 'uname -n')
    if [[ $?  != 0 ]]; then
      error "ERROR - ${_line}"
    elif [ "${_result}" != "${_line}" ]; then
      echo -e "NG - ${_line} <-> ${_result}"
    else
      echo -e "OK - ${_line}"
    fi
  done <<-'END'
w01
w01
END
}

setup
testCommand
