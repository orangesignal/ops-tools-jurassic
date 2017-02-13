#!/bin/bash -e

#ssh_config=
#passlist=

function include() {
  declare -r self_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
  source "${self_dir}/lib/functions"
}
include

function ops_root_test() {
  local result=$(ops_cmd "${1}" 'hostname')
  if [ "${result}" = "$1" ]; then
    echo -e "${TEXT_GREEN}OK - ${1}${TEXT_RESET}"
    return 0
  else
    echo -e "${TEXT_RED}NG - ${1} <-> ${result}${TEXT_RESET}"
    return 1
  fi
}

while read line; do
  ifs_save=$IFS
  IFS='	'
  set -- ${line}
  IFS=${ifs_save}

  case "${1:?}" in
    \#* )
#      echo -e "${TEXT_YELLOW}SKIP - ${1}${TEXT_RESET}"
      ;;
    * )
      ops_root_test "${1}"
      ;;
  esac
done < "${passlist}"
