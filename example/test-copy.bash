#!/bin/bash -eu

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

src="$(pwd)/test-copy-$(date +%Y%m%d%H%M%S)"
dest="/var/tmp/foobar"

mkdir -p "${src}"
touch "${src}/foo.txt"
touch "${src}/foo.html"
touch "${src}/bar.txt"
touch "${src}/bar.html"
mkdir -p "${src}/baz"
touch "${src}/baz/baz.txt"
touch "${src}/baz/baz.html"

while read line; do
  ../ops copy -F ./ssh_config -q -l 1024 "${line}" "${src}" "${dest}" -backup yes > /dev/null 2>&1
  ret=$?
  ../ops cmd -F ./ssh_config -q "${line}" "find ${dest} && rm -rf ${dest}"
done <<'END'
w01
END

rm -rf "${src}"
popd > /dev/null 2>&1
