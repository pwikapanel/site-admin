#!/usr/bin/env bash

# vim: set foldmethod=marker fmr=#——,## :

#———————————————————————————————————————— constants

# https://stackoverflow.com/questions/1508490/erase-the-current-printed-console-line
# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html

  repo="/opt/admin"

  bold=`echo $'\e[1m'`
normal=`echo $'\e[0m'`

       up="\033[1A" # move up 1 line, same column
beginning="\r"      # return to 0 position
    erase="\033[2K" # erase current line

erase_line="$beginning$erase"
scroll_line="\n$up"      # leave one extra empty line at bottom of window
##
#———————————————————————————————————————— check that /opt/delete.txt exists and is not empty

if [ -s /opt/delete.txt ]; then
  rien=0
else
  printf "\n  account creation canceled — $bold/opt/""delete.txt$normal is missing or empty\n\n"
  return 1
fi
##

#:::::::::::::::::::::::::::::::::::::::: FUNCTIONS

#———————————————————————————————————————— split string on delimiter

# https://stackoverflow.com/a/44153302/72958

split() {
  local string="$1"
  local delimiter="$2"
  if [ -n "$string" ]; then
    local part
    while read -d "$delimiter" part; do
      echo $part
    done <<< "$string"
    echo $part
  fi
}
##
#———————————————————————————————————————— check if directory is missing

  dir_missing() { [[ ! -d $1 ]]; }
##  

#:::::::::::::::::::::::::::::::::::::::: PROGRAM

#———————————————————————————————————————— change to opt dir

cd /opt
##
#———————————————————————————————————————— initialize results

qty=0
##
#———————————————————————————————————————— back up rsyncd files

  cp /etc/rsyncd.conf /etc/rsyncd.conf.bk #√
  cp /etc/rsyncd.scrt /etc/rsyncd.scrt.bk #√

  printf "\n$scroll_line  rsyncd files backed up\n"
##
#———————————————————————————————————————— confirm deletion

printf "\n  $bold""delete.txt$normal contains:\n$bold"

while IFS= read -r line; do
	printf "\n  $line"
done < /opt/delete.txt

printf "$normal\n"

msg="\n$line_below$line_below  do you want to continue (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "\n  account deletion canceled\n\n"
  return 1
fi
##

#::::::::::::::::::::::::::::::::::::::::▼ begin loop

while IFS= read -r line; do

#———————————————————————————————————————— generate user credentials

  mapfile -t array < <(split $line ":")

# url:sync ID:home folder
 
  url="${array[0]}"
  user_name="${array[1]}"
  django_name="${array[2]}"
  user_dir="/home/$django_name"

	printf "\n$scroll_line  deleting $bold$url$normal"
##
#———————————————————————————————————————— check for user's directory

  if dir_missing $user_dir; then
    printf "\n  $bold⚠️  $url not deleted:$normal $user_dir is missing\n\n"
    return 1
  fi
  
  printf "\n  └── site folder exists\n\n"
##
#———————————————————————————————————————— delete user, group & folder

  delgroup $user_name #√
  printf "\n$scroll_line  ├── debian group $user_name deleted"

  # from chatgpt
  # Kill all processes owned by the user
  pkill -u "$user_name"
  
  # Wait a moment to ensure they're gone
  sleep 1
  
  # Force kill if anything is still running
  if pgrep -u "$user_name" > /dev/null; then
      pkill -9 -u "$user_name"
  fi
  
  # Now delete the user
  deluser --remove-home "$user_name"

  printf "\n$scroll_line  ┌── debian user $user_name deleted"

  rm -rf $user_dir #√
  printf "\n$scroll_line  ├── $user_dir deleted"
##
#———————————————————————————————————————— delete nginx configs

  rm /etc/nginx/sites-available/$django_name #√
  rm /etc/nginx/sites-enabled/$django_name   #√

  printf "\n$scroll_line  ├── nginx configs deleted"
##
#———————————————————————————————————————— delete uwsgi configs

  rm /etc/uwsgi/sites/$django_name.ini #√

  printf "\n$scroll_line  ├── uwsgi config deleted"
##
#———————————————————————————————————————— delete certbot configs

  rm /etc/letsencrypt/renewal/$url.conf #√
  rm -rf /etc/letsencrypt/archive/$url/ #√
  rm -rf /etc/letsencrypt/live/$url/ #√

  printf "\n$scroll_line  ├── certbot configs deleted"
##
#———————————————————————————————————————— delete rsyncd password

# vi -O /etc/rsyncd.conf /etc/rsyncd.scrt
# https://www.baeldung.com/linux/delete-lines-containing-string-from-file
# princetonprintingtx:1ZyosxDcOAj51WIh

  sed -i "/^$user_name\:.*$/d" /etc/rsyncd.scrt #√

  printf "\n$scroll_line  ├── rsyncd.scrt updated"
##
#———————————————————————————————————————— delete rsyncd user

# vi -O /etc/rsyncd.conf /etc/rsyncd.scrt
# https://www.baeldung.com/linux/delete-lines-containing-string-from-file
# princetonprintingtx:1ZyosxDcOAj51WIh

# get line # of [user_name]
# delete 11 lines

# https://stackoverflow.com/questions/20026370/using-bash-script-to-find-line-number-of-string-in-file
# https://stackoverflow.com/questions/2112469/delete-specific-line-numbers-from-a-text-file-using-sed
# awk '/line/{ print NR; exit }' input-file

  firstline=$(awk "/^\[$user_name\]$/{ print NR; exit }" /etc/rsyncd.conf) #√

  #rintf "\n---------------------------$firstline"

  lastline=$(($firstline + 10)) #√
  #rintf "\n---------------------------$lastline"

  # a "," error just means the string wasn't found

  #rintf "\n--------------------------- $firstline,$lastline""d"
  sed -i "$firstline"",""$lastline""d" /etc/rsyncd.conf #√

  printf "\n$scroll_line  └── rsyncd.conf updated\n\n"
##
#———————————————————————————————————————— drop postgresql database & role

# CREATE USER django_name*user WITH PASSWORD 'password*';
# ALTER ROLE django_name*user SET client_encoding TO 'utf8';
# ALTER ROLE django_name*user SET default_transaction_isolation TO 'read committed';
# ALTER ROLE django_name*user SET timezone TO 'Europe/Paris';
# CREATE DATABASE django_name*db;
# GRANT ALL PRIVILEGES ON DATABASE django_name*db TO django_name*user;

# stringtoexecute="DROP DATABASE $django_name""db; DROP ROLE $django_name""user;" #√
  stringtoexecute="DROP DATABASE $django_name""db; ALTER SCHEMA public OWNER TO postgres; DROP OWNED BY $django_name""user; DROP ROLE $django_name""user;"

sudo -u postgres psql -f - <<EOF
  $stringtoexecute
EOF

  printf "\n$scroll_line  ┌── postgresql database & role dropped"
##
#———————————————————————————————————————— increment counter & notify of completion

  qty=$((qty + 1))
  printf "\n$scroll_line  $bold$url$normal deleted\n"
  cd /opt
##

#:::::::::::::::::::::::::::::::::::::::: ▲ end loop

done < /opt/delete.txt

#———————————————————————————————————————— clean up & exit

#m /opt/delete.txt
cd /opt
printf "\n$scroll_line  restarting $bold""NginX$normal...\n"
service nginx restart
##
#———————————————————————————————————————— notify user

printf "\n  $bold""PROGRAM COMPLETE$normal"
printf "\n  • $qty account(s) deleted\n\n"
##

#:::::::::::::::::::::::::::::::::::::::: fin
