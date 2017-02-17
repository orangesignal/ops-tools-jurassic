#!/bin/bash

function include() {
  declare -r self_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
  source "${self_dir}/lib/functions"
}
include

#ssh_config=
#passlist=
#listfile=

while read line; do
  ifs_save=$IFS
  IFS='	'
  set -- ${line}
  IFS=${ifs_save}

  count=$(ops_service "${1}" "${2}" 'stop')
  code=$?
  if [ ${code} -eq 0 ]; then
    if [ ${count} -eq 0  ]; then
      echo -e "${TEXT_GREEN}OK - ${1} ${2} stop ${TEXT_RESET}"
    else
      echo -e "${TEXT_RED}NG - ${1} ${2} stop -> process count: ${count}${TEXT_RESET}"
    fi
  else
    echo -e "${TEXT_RED}ERROR - ${1} ${2} stop -> error code: ${code}${TEXT_RESET}"
  fi
done < "${listfile}"
