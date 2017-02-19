#!/bin/bash -eu

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
trap 'popd > /dev/null 2>&1' SIGINT EXIT

while read line; do
  result=$(../ops cmd -F ./ssh_config -q "${line}" 'uname -n')
  ret=$?
  if [[ $ret  != 0 ]]; then
    error "ERROR - ${line}"
  elif [ "${result}" != "${line}" ]; then
    echo -e "NG - ${line} <-> ${result}"
  else
    echo -e "OK - ${line}"
  fi
done <<'END'
w01
END
