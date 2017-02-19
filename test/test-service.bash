#!/bin/bash -eu

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

while read line; do
  set -- ${line}
  result=$(../ops service -F ./ssh_config "$@")
  ret=$?
  if [[ $ret  != 0 ]]; then
    error "ERROR - $@"
  else
    echo "$@ - result: ${result}"
  fi
done <<'END'
w01	jenkins	stop
w01	jenkins	start
w01	jenkins	restart
END

popd > /dev/null 2>&1
