#!/bin/bash -euf

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1

base="test-copy-$(date +%Y%m%d%H%M%S)"
src_dir="$(pwd)/${base}"
dest_dir="/var/tmp/foobar"

trap 'rm -rf "${src_dir}"; popd > /dev/null 2>&1' SIGINT EXIT

mkdir "${src_dir}"
touch "${src_dir}/foo.txt"
touch "${src_dir}/foo.html"
touch "${src_dir}/bar.txt"
touch "${src_dir}/bar.html"
mkdir "${src_dir}/baz"
touch "${src_dir}/baz/baz.txt"
touch "${src_dir}/baz/baz.html"

while read line; do
  case "${line}" in
    \#* )
      echo "skip: $line"
      continue;
      ;;
    * )
      echo "line: $line"
      ;;
  esac
  set -- ${line}
  ../ops cmd -F ./ssh_config -q "${1}" "mkdir ${dest_dir}"
  ../ops copy -F ./ssh_config -q -l 1024 "$@"
  ../ops cmd -F ./ssh_config -q "${1}" "find ${dest_dir} | sort && rm -rf ${dest_dir}"
  echo ''
done <<END
w01 ${src_dir}/foo.txt ${dest_dir}
w01 ${src_dir}/foo.txt ${dest_dir}/renamed-foo.txt
w01 ${src_dir}         ${dest_dir}
w01 ${src_dir}/        ${dest_dir}/
#w01 ${src_dir}/*.txt   ${dest_dir}
END

