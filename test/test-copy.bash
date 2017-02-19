#!/bin/bash -eu

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

src="$(pwd)/test-copy-$(date +%Y%m%d%H%M%S)"
dest="/var/tmp/foobar"

trap 'rm -rf "${src}"; popd > /dev/null 2>&1' SIGINT EXIT

mkdir -p "${src}"
touch "${src}/foo.txt"
touch "${src}/foo.html"
touch "${src}/bar.txt"
touch "${src}/bar.html"
mkdir -p "${src}/baz"
touch "${src}/baz/baz.txt"
touch "${src}/baz/baz.html"

while read hostname; do
  ../ops copy -F ./ssh_config -q -l 1024 "${hostname}" "${src}" "${dest}" -backup yes
  ret=$?
  ../ops cmd -F ./ssh_config -q "${hostname}" "find ${dest} && rm -rf ${dest}"
done <<'END'
w01
END
