#!/bin/bash
# backup.sh
source /opt/venv/djangoEnv/bin/activate

#———————————————————————————————————————— do first

#  first update /opt/sitelist.txt

#  run from /opt/, leave in /version-update folder

#  to get currently installed version:
#  vi [site]/static/admin/css/admin-extra.css
#  vi /var/www/Env/djangoEnv/lib/python3.6/site-packages/svija/templates/admin/base_site.html

#———————————————————————————————————————— text styles

cd /opt/site-mgmt

  bold=`echo $'\e[1m'`
normal=`echo $'\e[0m'`

#———————————————————————————————————————— check that /opt/version.txt exists and is not empty

if [ -s /opt/version.txt ]; then
  rien=0
else
  printf "\n  backup canceled — $bold/opt/version.txt$normal is missing or empty\n"
  printf "\n $bold vi ../version.txt$normal\n\n"
  cd /opt
  return 1
fi

#———————————————————————————————————————— date & version strings

datestr=$(date +%y%m%d)
read -r version < ../version.txt

printf "\n     date: $bold$datestr$normal"
printf "\n  version: $bold$version$normal\n"

#———————————————————————————————————————— confirm sitelist.txt

printf "\n  $bold""sitelist.txt$normal contains:\n\n"

head /opt/sitelist.txt

msg="\n  $bold""is this correct$normal (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "\n  $bold""directory listing:$normal\n\n"
  ls -l /home | grep ^d
  printf "\n $bold vi ../sitelist.txt$normal\n\n"
  return 1
fi

#———————————————————————————————————————— initialize

place='/opt/backups'
backupdir="$place/$datestr-$version"

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
printf "\n   changed directory"

mkdir -p "$backupdir"
printf "\n   $bold$backupdir$normal created\n"

#———————————————————————————————————————— loop through accounts

while IFS= read -r line; do

  cd /home/$line
  ./manage.py dumpdata --indent 2 > "$backupdir/$line.json"
  printf "\n   /$bold$line$normal saved"

done < ../sitelist.txt

#———————————————————————————————————————— clean up

cd /opt
printf "\n\n   data export finished\n\n"

#———————————————————————————————————————— fin
