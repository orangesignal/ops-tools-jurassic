#!/bin/bash

set -e

function error() { echo -e "$@" 1>&2; }
function abort() { echo -e "$@" 1>&2; exit 1; }
function trace_run() { echo "+ $@"; "$@"; }

declare -r rsync_cmd=$(type -tap rsync || abort "ERROR - rsync is not installed or not in your PATH")
declare -r chown_cmd=$(type -tap chown || abort "ERROR - chown is not installed or not in your PATH")
declare -r chmod_cmd=$(type -tap chmod || abort "ERROR - chmod is not installed or not in your PATH")

declare -r src=${1:?}
declare -r dest="${2:?}"
declare -r owner="${3}"
declare -r mode="${4}"
declare -r backup="${5}"
declare -r suffix="${6:-${SIMPLE_BACKUP_SUFFIX:-~}}"

function basename() {
  echo "${1##*/}"
}

function doBackupIfNeed() {
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
    ${rsync_cmd} -a -q "${_backup_src}" "${_backup_dest}"
  fi
}

function doCopy() {
  # copy
  ${rsync_cmd} -a -q ${src} "${dest}"
  # chown
  if [[ "${owner}" != '' ]]; then
    ${chown_cmd} -R ${owner} "${dest}"
  fi
  # mode
  if [[ "${mode}" != '' ]]; then
    ${chmod_cmd} -R ${mode} "${dest}"
  fi
}

doBackupIfNeed
doCopy
