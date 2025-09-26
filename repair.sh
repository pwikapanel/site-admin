#!/usr/bin/env bash

# version 1.0.1

# would be better to have one argument for user and one argument for folder
# and some error checking, does folder exist

# can't "return 1" if not called with "source repair.sh"

#———————————————————————————————————————— constants

  bold=`echo $'\e[1m'`
normal=`echo $'\e[0m'`

#———————————————————————————————————————— program

msg="\n\n  repair $bold$1$normal — do you want to continue (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "\n  account repair canceled\n\n"
  return 1
fi

#———————————————————————————————————————— repair permissions

chown -R root: "/home/$1"
chmod -R 755 "/home/$1"
chown -R "$1":restricted "/home/$1/SYNC"

#———————————————————————————————————————— finish up

printf "\n  $bold$1 repaired$normal\n\n"
