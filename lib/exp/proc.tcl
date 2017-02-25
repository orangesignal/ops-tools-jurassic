#!/bin/env tclsh

proc error { msg } {
  send_error -- "$msg"
}

proc abort { msg } {
  send_error -- "$msg"
  exit 1
}

proc assertNotEmpty { var { msg "assertion failed" } } {
  if { $var eq "" } { abort $msg }
}

proc defaultString { str defaultStr } {
  if { $str eq "" } {
    return $defaultStr
  }
  return $str
}