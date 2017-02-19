#!/bin/bash -eu

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

while read line; do
  set -- ${line}
  dest="$(pwd)/test-fetch-$(date +%Y%m%d%H%M%S)"
  rm -rf "${dest}"
  ../ops fetch -F ./ssh_config -q -l 1024 "$@" "${dest}"
  ret=$?
  find "${dest}"
done <<'END'
w01 /var/spool/cron
END

popd > /dev/null 2>&1
