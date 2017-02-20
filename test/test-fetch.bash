#!/bin/bash -euf

pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
dest_dir="$(pwd)/test-fetch-$(date +%Y%m%d%H%M%S)"
trap 'rm -rf "${dest_dir}"; popd > /dev/null 2>&1' SIGINT EXIT
mkdir -p "${dest_dir}"

while read line; do
  echo "line: $line"
  set -- ${line}
  ../ops fetch -F ./ssh_config -q -l 1024 "$@"
done <<END
w01 /etc/*.conf     ${dest_dir}/conf
w01 /var/spool/cron ${dest_dir}
w01 /etc/init.d/    ${dest_dir}/init.d/
w01 /var/log/syslog ${dest_dir}
w01 /var/log/syslog ${dest_dir}/renamed-syslog
END

find "${dest_dir}"
