#!/usr/bin/env bash

# vim: set foldmethod=marker fmr=#——,## :

#:::::::::::::::::::::::::::::::::::::::: version 1.0.2

#———————————————————————————————————————— constants

# https://stackoverflow.com/questions/1508490/erase-the-current-printed-console-line
# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html

  repo="/opt/site-mgmt"

  bold=`echo $'\e[1m'`
normal=`echo $'\e[0m'`

       up="\033[1A" # move up 1 line, same column
#eginning="\n$up"
beginning="\r"      # return to 0 position
    erase="\033[2K" # erase current line

erase_line="$beginning$erase"
line_below="\n$up"      # leave one extra empty line at bottom of window
##
#———————————————————————————————————————— check that /opt/create.txt exists and is not empty

printf "\n"

if [ -s /opt/create.txt ]; then
  rien=0
else
  printf "\n  account creation canceled — $bold/opt/""create.txt$normal is missing or empty\n\n"
  return 1
fi
##
#———————————————————————————————————————— confirm that DNS has been configured

msg="\n$line_below  $bold""RESTART IF NECESSARY$normal\n\n  has $bold""SYNC Folder$normal been updated? (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "  account creation canceled\n\n"
  return 1
fi
##
#———————————————————————————————————————— confirm that DNS has been configured

msg="$line_below  have $bold""DNS records$normal been configured (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "  account creation canceled\n\n"
  return 1
fi
##
#———————————————————————————————————————— confirm that certbot has already been run once

msg="$line_below  has $bold""Certbot$normal been configured on this server (y/n)? "

printf "$msg" && read -n1 dns && printf "\n";

if [[ "$dns" != "y" ]]; then
  printf "\n  account creation canceled — certbot requires an email address"
  printf "\n  please type $bold""certbot$normal to configure (cancel when asked for a domain name)\n\n"
  return 1
fi
##

#:::::::::::::::::::::::::::::::::::::::: FUNCTIONS

#———————————————————————————————————————— change case

to_upper(){ echo "$1" | tr a-z A-Z; }
to_lower(){ echo "$1" | tr A-Z a-z; }
##
#———————————————————————————————————————— random number in a range

random_integer(){
  min=$1
  max=$2
  echo $((min + $RANDOM % max))
}
##
#———————————————————————————————————————— one random character

possible_chars="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

one_random_character(){
  which_char=$(random_integer 1 61)
  substr="${possible_chars:$which_char:1}"
  echo "$substr"
}
##
#———————————————————————————————————————— create postgre password

password(){
  results=""
  for i in {0..15}; do
    x=$(one_random_character)
    results="$results$x"
  done
  echo $results
}

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

#———————————————————————————————————————— check if directory is missing

  dir_missing() { [[ ! -d $1 ]]; }
  
#———————————————————————————————————————— check if directory exists

  dir_exists() { [[ -d $1 ]]; }
  
#———————————————————————————————————————— check if file is missing

file_missing() { [[ ! -f $1 ]]; }


#:::::::::::::::::::::::::::::::::::::::: PROGRAM

#———————————————————————————————————————— start venv

source /opt/venv/djangoEnv/bin/activate

#———————————————————————————————————————— initialize results

qty=0
all_codes=""
rm -rf /opt/errors.txt


#::::::::::::::::::::::::::::::::::::::::▼ begin loop

while IFS= read -r line; do

#———————————————————————————————————————— read from create.txt

  mapfile -t array < <(split $line ":")
 
  url="${array[0]}"

  sync_src="/opt/${array[1]}"
  folder="${array[2]}"

  ubuntu_user="${array[3]}"
  ubuntu_pw="${array[4]}"

  cloud_user="${array[5]}"
  cloud_pw="${array[6]}"

  first_name="${array[7]}"
  last_name="${array[8]}"
  email="${array[9]}"
  time_zone="${array[10]}"

	printf "\n$line_below  creating $bold$url$normal"

#———————————————————————————————————————— correct input if missing
#
#   because as of september 2023, the SYNC folder and home folder
#   are not present in the spread sheet (columns PC & Mac)

#   www.wellcom.svija.site x   wellcom ycF2A9Bn86HfpwkQ  wellcom ycF2A9Bn86HfpwkQ  Mamadou Diao  diao654@gmail.com Etc/GMT

if [[ "$sync_src" == "/opt/x" || "$sync_src" == "/opt/" ]]; then
  sync_src="/opt/SYNCFR"
fi

if [[ $folder == "x" ]]; then
  folder="$ubuntu_user"
fi

if [ -z "${folder-unset}" ]; then
  folder="$ubuntu_user"
fi

#———————————————————————————————————————— keep codes for output when done

  user_codes="$url\t\t\t$ubuntu_user\t$ubuntu_pw\t$cloud_user\t$cloud_pw\t$first_name\t$last_name\t$email"

  all_codes="$all_codes\n$user_codes"

#———————————————————————————————————————— check for SYNC* & *.json

  if dir_missing $sync_src; then
    printf "\n  $bold⚠️  $url not installed:$normal $sync_src is missing\n\n"
    return 1
  fi
  
  if file_missing $sync_src/*.json; then
      printf "\n  $bold⚠️  $url not installed:$normal JSON file is missing\n\n"
    return 1
  fi
  
  printf "\n  ├── SYNC folder & JSON file exist"

#———————————————————————————————————————— check that folder doesn't exist

  folder_path="/home/$folder"

  if dir_exists $folder_path; then
    printf "\n$line_below  $bold⚠️  $url not installed:$normal folder $folder_path already exists\n\n"
    cd /opt
    return 1
  fi

#———————————————————————————————————————— start django project & cd

  django_proj="$folder"
  mkdir -p $folder_path/cache
  cd $folder_path

# chown $django_proj:www-data /home/$django_proj/cache

  django-admin startproject $django_proj $folder_path # need both because folder already exists
  printf "\n$line_below  ├── django project $django_proj started in $folder_path"

#———————————————————————————————————————— copy required files to the new directory

  cp -r $repo/required/* ./

  printf "\n$line_below  ├── required files copied"

#———————————————————————————————————————— update credentials in /required/*

  #   | takes output from left as input for right side
  #  
  #   xargs replaces
  #  
  #     [command] | while read param; do
  #       [traitement]
  #     done
  #  
  #   sed -i means edit in place

  # first so that cloud_pw* isn't replaced by a search for pass*

  # Ubuntu
  grep -rl 'url\*'         . | xargs sed -i "s/url\*/$url/g"
  grep -rl 'ubuntu_user\*' . | xargs sed -i "s/ubuntu_user\*/$ubuntu_user/g"
  grep -rl 'ubuntu_pw\*'   . | xargs sed -i "s/ubuntu_pw\*/$ubuntu_pw/g"
  grep -rl 'folder\*'      . | xargs sed -i "s/folder\*/$folder/g"
  grep -rl 'time_zone\*'   . | xargs sed -i "s;time_zone\*;$time_zone;g"

  # Svija Cloud
  grep -rl 'cloud_user\*'  . | xargs sed -i "s/cloud_user\*/$cloud_user/g"
  grep -rl 'cloud_pw\*'    . | xargs sed -i "s/cloud_pw\*/$cloud_pw/g"
  grep -rl 'first_name\*'  . | xargs sed -i "s/first_name\*/$first_name/g"
  grep -rl 'last_name\*'   . | xargs sed -i "s/last_name\*/$last_name/g"
  grep -rl 'email\*'       . | xargs sed -i "s/email\*/$email/g"

  # Django & Postgres
  django_pw=$(password)    # unknown to user — present in settings.py
  grep -rl 'django_pw\*'   . | xargs sed -i "s/django_pw\*/$django_pw/g"
  grep -rl 'django_proj\*' . | xargs sed -i "s/django_proj\*/$django_proj/g"


  printf "\n$line_below  ├── required files updated"

#———————————————————————————————————————— copy SYNC folder

# must be after sed so files don't get corrupted

  printf "\n$line_below  ├── copying SYNC folder..."
  cp -r $sync_src "./SYNC"
  cp -r $sync_src "./RESET"

  # fixes bug in Svija Sync, shouldn't be necessary
  echo -n "Site Creator" > "SYNC/.last"

  # add URL.txt file
  #kdir SYNC/SVIJA/System
  echo -n "$url" > "SYNC/SVIJA/System/URL.txt"

  printf "$erase_line  ├── SYNC folder copied"

#———————————————————————————————————————— cat urls.py settings.py 

  cat urls.py >> $django_proj/urls.py
  rm urls.py

  cat settings.py >> $django_proj/settings.py
  rm settings.py

  printf "\n$line_below  ├── urls.py & settings.py updated"

#———————————————————————————————————————— create database

  sudo -u postgres psql -f postgres.sql >> /opt/errors.txt 2>&1
  rm postgres.sql

  printf "\n$line_below  ├── database created"

#———————————————————————————————————————— migrations

  printf "\n$line_below  ├── applying migrations · 8s..."

  ./manage.py migrate --run-syncdb >> /opt/errors.txt 2>&1

  printf "$erase_line  ├── migrations applied"

#———————————————————————————————————————— contentTypes.py

  chmod 777 contentTypes.py
  ./contentTypes.py

  rm contentTypes.py

  printf "\n$line_below  ├── ContentTypes framework deleted"

#———————————————————————————————————————— load json

  printf "\n$line_below  ├── importing JSON data · 3s..."
  ./manage.py loaddata SYNC/*.json >> /opt/errors.txt 2>&1

  rm -f SYNC/*.json

  printf "$erase_line  ├── JSON data imported"

#———————————————————————————————————————— collect static

  printf "\n$line_below  ├── collecting static files..."

  ./manage.py collectstatic --noinput >> /opt/errors.txt 2>&1

  printf "$erase_line  ├── static files collected"

#———————————————————————————————————————— nginx config

  mv nginx_config /etc/nginx/sites-available/$folder

  ln -s /etc/nginx/sites-available/$folder /etc/nginx/sites-enabled

  printf "\n$line_below  ├── nginx configured"

#———————————————————————————————————————— uwsgi config

  mv uwsgi_config.ini /etc/uwsgi/sites/$folder.ini
# chown -R $ubuntu_user:$ubuntu_user SYNC   # superseded by FTP mods below
  printf "\n$line_below  ├── uwsgi configured"

#———————————————————————————————————————— create ubuntu user

# useradd -d /home/$folder/SYNC $ubuntu_user
  useradd -d /home/$folder $ubuntu_user
  
# chown -R limited:limited ./
# chown -R $ubuntu_user:$ubuntu_user SYNC   # superseded by FTP mods below
# chmod -R 755 SYNC/

# FTP user permissions

# can be consolidated
# https://github.com/svijasvg/site-mgmt/blob/beta/ftp-users.md

# user_codes="$url\t\t\t$ubuntu_user\t$ubuntu_pw\t$cloud_user\t$cloud_pw\t$first_name\t$last_name\t$email"

# usermod -d /home/$folder $ubuntu_user
  usermod -s /bin/false $ubuntu_user
  usermod -g restricted $ubuntu_user

  chmod 755 /home/$django_proj/cache

  chown -R root: /home/$folder
  chmod -R 755 /home/$folder

# chmod -R 755 /home/$folder/SYNC
  chown -R $ubuntu_user:restricted /home/$folder/SYNC

  echo "$ubuntu_user:$ubuntu_pw" | chpasswd

#rintf "\n  Don't forget to do $bold""echo \"USER:PASS\" | chpasswd$normal for any FTP users.\n$bold  Restart the server$normal before notifying users\n\n"

  printf "\n$line_below  ├── ubuntu user created"

  mkdir -p /opt/logs/$folder
  chown $django_proj:www-data /opt/logs/$folder
  chmod 755 /opt/logs/$folder                        # may not be necessary
  chown $django_proj:www-data /home/$folder/cache

#———————————————————————————————————————— django user account

  if [[ "$cloud_user" != "" ]]; then
    echo 'import cloud_updates.py' | python manage.py shell >> /opt/errors.txt 2>&1

    rm cloud_updates.py

    printf "\n$line_below  ├── Svija Cloud user created"
  fi

#———————————————————————————————————————— rsync dæmon

  cat rsyncd.conf >> /etc/rsyncd.conf
  rm rsyncd.conf

  cat rsyncd.scrt >> /etc/rsyncd.scrt
  rm rsyncd.scrt

  printf "\n$line_below  ├── rsync dæmon configured"

#———————————————————————————————————————— enable certbot/https

  printf "\n$line_below  ├── enabling https · 10s..."

  certbot --nginx -d "$url" &>> /opt/certbot.txt

  printf "$erase_line  ├── https enabled"

#———————————————————————————————————————— increment counter & notify of completion

  qty=$((qty + 1))
  printf "\n$line_below  $bold$url$normal created\n"
  cd /opt


#:::::::::::::::::::::::::::::::::::::::: ▲ end loop

done < /opt/create.txt

#———————————————————————————————————————— clean up & exit

deactivate
cd /opt
service rsync restart

#———————————————————————————————————————— notify user

printf "\n  $bold""PROGRAM COMPLETE$normal & rsync restarted"
printf "\n  • $qty account(s) created"
printf "\n  • any errors written to $bold/opt/errors.txt$normal"

# certbot

printf "\n\n$line_below  press any key to see $bold""certbot$normal output: " && read -n1 x

printf "\n\n$bold" && tail -n +1 /opt/certbot.txt

rm /opt/certbot.txt
printf "$normal"

#———————————————————————————————————————— login codes COMMENTED OUT

#rintf "\n  if each domain name shows $bold""Successfully received certificate$normal, you can safely"
#rintf "\n$line_below  paste the following codes into $bold""columns F-M$normal of the $bold""login spreadsheets$normal:\n$bold$all_codes$normal\n"


#:::::::::::::::::::::::::::::::::::::::: fin
