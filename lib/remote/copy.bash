#!/bin/bash

set -e

src=${1:?}
dest="${2:?}"
owner="${3}"
mode="${4}"
backup="${5}"
suffix="${6:-${SIMPLE_BACKUP_SUFFIX:-~}}"

old_backup="${backup}"

if [ -e "${dest}" ]; then
  if [ "${backup}" != '' ]; then
    # moving old backup directory
    while [ -e "${old_backup}" ]; do
      old_backup="${old_backup}${suffix}"
    done
    if [ "${backup}" != "${old_backup}" ]; then
      mv "${backup}" "${old_backup}"
    fi

    # backup
    rsync -avh "${dest}" "${backup}"
  fi
fi

# copy
rsync -avh ${src} "${dest}"

# chown
if [ "${owner}" != '' ]; then
  chown -R ${owner} "${dest}"
fi

# mode
if [ "${mode}" != '' ]; then
  chmod -R ${mode} "${dest}"
fi
