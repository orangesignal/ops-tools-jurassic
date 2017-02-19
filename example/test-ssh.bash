#!/bin/bash -eu

list=$(cat <<'END'
w01
END
)

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

for host in $(echo "$list"); do
  result=$(../ops ssh -F ./ssh_config -q "${host}" 'uname -n')
  ret=$?
  if [[ $ret  != 0 ]]; then
    error "ERROR - ${host}"
  elif [ "${result}" != "${host}" ]; then
    echo -e "NG - ${host} <-> ${result}"
  else
    echo -e "OK - ${host}"
  fi
done

popd > /dev/null 2>&1
