#!/bin/bash -e

function include() {
  declare -r self_dir="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
  source "${self_dir}/lib/functions"
}
include

ops_service "${1}" "${2}" "${3}"
