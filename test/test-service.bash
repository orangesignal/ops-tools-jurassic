#!/bin/bash -u

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  trap 'onExit' SIGINT EXIT
}

function onExit() {
  popd > /dev/null 2>&1
}

function testService() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  while read -r _line; do
    set -- ${_line}
    local result=$(../ops -n -F ./ssh_config service "$@")
    if [[ $?  != 0 ]]; then
      error "ERROR - $@"
    else
      echo "$@ - result: ${result}"
    fi
  done <<-'END'
w01	jenkins	stop
w01	jenkins	start
w01	jenkins	restart
END
}

setup
testService
