#!/bin/bash

set -e

declare -r act="${1:-'doCopy'}"
declare -r src=${2:?}
declare -r dest="${3:?}"
declare -r owner="${4}"
declare -r mode="${5}"
declare    backup="${6}"
declare -r suffix="${7:-${SIMPLE_BACKUP_SUFFIX:-~}}"

function doBackup() {
  if [[ -e "${dest}" ]]; then
    if [[ "${backup}" != '' ]]; then
      if [[ "${backup}" == 'yes' ]]; then
        backup="${dest}"
      fi
      backup="$(echo ${backup} | sed 's|/$||g')"
      local backup_path="${backup}"
      while [[ -e "${backup_path}" ]]; do
        backup_path="${backup_path}${suffix}"
      done
      # backup
      rsync -a -q "${dest}" "${backup_path}"
    fi
  fi
}

function doCopy() {
  # copy
  rsync -a -q ${src} "${dest}"
  # chown
  if [[ "${owner}" != '' ]]; then
    chown -R ${owner} "${dest}"
  fi
  # mode
  if [[ "${mode}" != '' ]]; then
    chmod -R ${mode} "${dest}"
  fi
}

eval "${act}"