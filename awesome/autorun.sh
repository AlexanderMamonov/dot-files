#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run xxkb
run setxkbmap -layout "us,ru" -option "grp:ctrl_shift_toggle"
