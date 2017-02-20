#!/bin/bash

set -e

declare -r act="${1:-'doCopy'}"
declare -r src=${2:?}
declare -r dest="${3:?}"
declare -r owner="${4}"
declare -r mode="${5}"
declare -r backup="${6}"
declare -r suffix="${7:-${SIMPLE_BACKUP_SUFFIX:-~}}"

function basename() {
  echo "${1##*/}"
}

function doBackup() {
  local _backup_src="${dest}"
  local _backup_dest=

  # file -> dir copy pattern [/foo/bar.txt /foo]
  if [[ -f "${src}" ]] && [[ -d "${_backup_src}" ]]; then
    _backup_src="$(cd "${_backup_src}" && pwd)/$(basename "${src}")"
  fi

  # validate backup environment
  if [[ -e "${_backup_src}" ]] && [[ "${backup}" != '' ]]; then
    # set backup_dest
    if [[ "${backup}" == 'yes' ]]; then
      _backup_dest="${_backup_src}"
    else
      _backup_dest="${backup}"
    fi
    # remove last slash
    if [[ -d "${_backup_dest}" ]]; then
      _backup_dest="$(cd "${_backup_dest}" && pwd)"
    fi

    while [[ -e "${_backup_dest}" ]]; do
      _backup_dest="${_backup_dest}${suffix}"
    done
    # backup
    rsync -a -q "${_backup_src}" "${_backup_dest}"
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