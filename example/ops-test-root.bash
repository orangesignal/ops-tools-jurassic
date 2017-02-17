#!/bin/bash -e
# 
# root switch test
# 

self_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
source "${self_dir}/lib/functions"

ssh_config="${self_dir}/ssh_config"
passlist="${self_dir}/passlist"

function test_root() {
  local result=$(ops_cmd "${1}" 'uname -n')
  local ret=$?
  if [ $ret  -ne 0 ]; then
    error "${TEXT_RED}ERROR - ${1}${TEST_RESET}"
    return $ret
  fi
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
      test_root "${1}"
      ;;
  esac

done < "${passlist}"
