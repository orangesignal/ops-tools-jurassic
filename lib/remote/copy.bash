#!/bin/bash

set -e

src=${1:?}
dest="${2:?}"
owner="${3}"
mode="${4}"
backup="${5}"
suffix="${6:-${SIMPLE_BACKUP_SUFFIX:-~}}"

if [[ -e "${dest}" ]]; then
  if [[ "${backup}" != '' ]]; then
    backup_path="${backup}${suffix}"

    while [[ -e "${backup_path}" ]]; do
      backup_path="${backup_path}${suffix}"
    done

    # backup
    rsync -a -q "${dest}" "${backup_path}"
  fi
fi

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
