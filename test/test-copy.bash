#!/bin/bash -euf

function setup() {
  pushd "$(dirname "$BASH_SOURCE")" > /dev/null 2>&1
  src_dir="$(pwd)/test-copy-$(date +%Y%m%d%H%M%S)"
  dest_dir="/var/tmp/foobar"
  trap 'onExit' SIGINT EXIT

  mkdir "${src_dir}"
  echo 'foo text' > "${src_dir}/foo.txt"
  echo 'foo html' > "${src_dir}/foo.html"
  echo 'bar text' > "${src_dir}/bar.txt"
  echo 'bar html' > "${src_dir}/bar.html"
  mkdir "${src_dir}/baz"
  echo 'baz text' > "${src_dir}/baz/baz.txt"
  echo 'baz html' > "${src_dir}/baz/baz.html"
}

function onExit() {
  rm -rf "${src_dir}"
  popd > /dev/null 2>&1
}

function testCopy() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  while read -r _line; do
    case "${_line}" in
      \#* ) continue ;;
      * )   echo "case: $_line" ;;
    esac
    set -- ${_line}
    ../ops cmd -F ./ssh_config -q "${1}" "mkdir ${dest_dir}"
    ../ops copy -F ./ssh_config -q -l 1024 "$@"
    ../ops cmd -F ./ssh_config -q "${1}" "find ${dest_dir} | sort && rm -rf ${dest_dir}"
    echo ''
  done <<END
w01 ${src_dir}/foo.txt ${dest_dir}
w01 ${src_dir}/foo.txt ${dest_dir}/renamed-foo.txt
w01 ${src_dir}         ${dest_dir}
w01 ${src_dir}/        ${dest_dir}/
w01 ${src_dir}/*.txt   ${dest_dir}
END
}

function testChangeOwnerAndChangeMode() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  while read -r _line; do
    case "${_line}" in
      \#* ) continue ;;
      * )   echo "case: $_line" ;;
    esac
    set -- ${_line}
    ../ops cmd -F ./ssh_config -q "${1}" "mkdir ${dest_dir}"
    ../ops copy -F ./ssh_config -q -l 1024 "$@"
    ../ops cmd -F ./ssh_config -q "${1}" "ls -l ${dest_dir} && rm -rf ${dest_dir}"
    echo ''
  done <<END
w01 ${src_dir}/foo.txt ${dest_dir} -owner root
w01 ${src_dir}/foo.txt ${dest_dir} -owner root:root
w01 ${src_dir}/foo.txt ${dest_dir} -mode +x
w01 ${src_dir}/foo.txt ${dest_dir} -mode 666
w01 ${src_dir}/foo.txt ${dest_dir} -owner root:root -mode 600
w01 ${src_dir}         ${dest_dir} -owner root
w01 ${src_dir}         ${dest_dir} -owner root:root
w01 ${src_dir}         ${dest_dir} -mode +x
w01 ${src_dir}         ${dest_dir} -mode 666
w01 ${src_dir}         ${dest_dir} -owner root:root -mode 600
END
}

# test backup
function testBackup() {
  echo "$FUNCNAME - $BASH_SOURCE"
  local _line=
  while read -r _line; do
    case "${_line}" in
      \#* ) continue ;;
      * )   echo "case: $_line" ;;
    esac
    set -- ${_line}
    local _flag="${1}"
    shift
    ../ops cmd -F ./ssh_config -q "${1}" "mkdir ${dest_dir}"
    case "${_flag}" in
      *\.txt )
        # setup no-empty file
        ../ops cmd -F ./ssh_config -q "${1}" "cp /var/log/syslog ${dest_dir}/${_flag}"
        ;;
      2 )
        ../ops copy -F ./ssh_config -q -l 1024 "$@"
        ;;
      3 )
        ../ops copy -F ./ssh_config -q -l 1024 "$@"
        ../ops copy -F ./ssh_config -q -l 1024 "$@"
        ;;
      bkdir )
        ../ops cmd -F ./ssh_config -q "${1}" "mkdir ${5}"
        ;;
      * )
        ;;
    esac
    ../ops copy -F ./ssh_config -q -l 1024 "$@"
    ../ops cmd -F ./ssh_config -q "${1}" "find ${dest_dir} | sort && rm -rf ${dest_dir}"
    echo ''
  done <<-END
# file
x       w01 ${src_dir}/foo.txt ${dest_dir}/foo.txt -backup yes
foo.txt w01 ${src_dir}/foo.txt ${dest_dir}/foo.txt -backup yes
foo.txt w01 ${src_dir}/*.txt   ${dest_dir}         -backup yes
foo.txt w01 ${src_dir}/foo.txt ${dest_dir}/foo.txt -backup yes                    -suffix "-$(date +%Y%m%d)"
foo.txt w01 ${src_dir}/foo.txt ${dest_dir}/foo.txt -backup ${dest_dir}/backup.txt -suffix "-$(date +%Y%m%d)"
# directory
x       w01 ${src_dir}/        ${dest_dir}/child/  -backup yes
2       w01 ${src_dir}/        ${dest_dir}/child/  -backup yes
2       w01 ${src_dir}/        ${dest_dir}/child/  -backup ${dest_dir}/backup
3       w01 ${src_dir}/        ${dest_dir}/child/  -backup ${dest_dir}/backup
END
}

setup
testCopy
testChangeOwnerAndChangeMode
testBackup
