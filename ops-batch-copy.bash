#!/bin/bash -e

#ssh_config=
#passlist=
copylist="${1:-copylist.tsv}"

function include() {
  declare -r self_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
  source "${self_dir}/lib/functions"
}
include

function ops_batch_copy() {
  declare -r ifs_save=$IFS
  IFS='	'
  for line in $(cat "${copylist}"); do
    set -- ${line}
    echo "$line"
    ops_copy "${1}" "${2}" "${3}" "${4}" "${5}"
    echo 'succes'
  done
  IFS=${ifs_save}
}

