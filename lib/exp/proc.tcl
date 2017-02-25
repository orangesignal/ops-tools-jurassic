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

proc getPrompt { buffer prompt } {
  set _lines [split $buffer "\n"]
  foreach line $_lines {
    if { [regexp $prompt $line] } {
      set _result "$line"
      break
    }
  }
  if { ![info exists _result] } {
    abort "Failed to get prompt line\n"
  }
  return $_result
}
