#!/usr/bin/env bash
#———————————————————————————————————————— config

site='beta01.svija.site'
user='beta01'
pass='rX6r9kfcSePSZGDy'

#———————————————————————————————————————— instructions
#
#    docs.svija.love/install
#
#———————————————————————————————————————— language independent

       version='1.1.7'
          lang='en'
          bold=`echo $'\e[1m'`
          none=`echo $'\e[0m'`

#———————————————————————————————————————— installation files

     readmedoc='README.md'
  scriptfolder='Scripts'
templatefolder='Templates'

#———————————————————————————————————————— localized keys

  keyup='U'
keydown='D'
 keyyes='Y'
  keyno='N'

#———————————————————————————————————————— localized strings

str01="Connection failure"
str02="Are you connected to the internet?"
str03="website:"
str04="   user:"
str05="   name:"
str06="your computer -> site:"
str07="your computer <- site:"
str08="Choose an option ($bold""Q$none to quit)"
str09="What is your first name?"
str10="Site was last modified by"
str11="2-30 letters, dash, period & space$none — $bold""no accents"
str12="Invalid choice"
str13="press Q"
str14="to close"
str15="Nothing to upload"
str16="Synchronization Canceled"
str17="This will replace folder \"SYNC\" on your computer"
str18="Are you sure?"
str19="Overwrite files on your computer?"
str20="Overwrite website files?"
str21="Synchronizing with $site"
str22="press space"
str23="please wait"
str24="Downloading from"
str25="Synchronization failed"
str26="Download complete"
str28="to stop"
str29="Uploading stopped"
str30="Downloading canceled"
str31="Uploading canceled"
str32="Do not close this window"
str33="pload"
str34="ownload"
str35="Svija needs permission to continue...\n\n    Computer "
colon=":"
question="?"

#———————————————————————————————————————— housekeeping strings

          bar="———————————————————————————————————————————————————————————————————————————"
 clear_screen="\e[2J\e"
   clear_1523="\e[15;0H\e[K\n\e[K\n\e[K\n\e[K\n\e[K\n\e[K\n\e[K\n\e[K\n  $bar\e[23;4H"
   clear_1923=""
   clear_2023="\e[20;0H\e[K\n\e[K\n\e[K\n  $bar\e[23;4H"
 clear_status="\e[23;0H\e[K  $bar\e[23;4H"
clear_command="\e[21;5H\e[K"

#———————————————————————————————————————— composed text

motd=$(curl -Ls msg.svija.love/$version/$lang.txt)

if [[ $motd == '' ]]; then
    motd="\n\n    $bold""$str01.$none\n\n    $str02\n\n"
fi

#———————————————————————————————————————— welcome & instructions

uload="$bold$keyup$none$str33"
dload="$bold$keydown$none$str34"

welcome="\e[3;0H$motd

  $bar

    Svija Sync V$version"

site_data="\e[14;5H$bold""$str03 $site
    $str04 $user
    $str05"

instructions="\e[18;5H$none$str06 $uload
    $str07 $dload"

#—————————————————————————————————————————————————— the rest

         whats_name="\e[21;0H    $bold""$str09$none ______________________________\e[30D"
         name_error="\e[23;4H $bold$str11$none "
     invalid_choice="\e[23;0H\e[K    $str12 — $bold""$str13$none $str14$colon ___\e[2D"

    request_command="$clear_command$str08 ___\e[2D"
  nothing_to_upload="$bold$str15!$none"
uploading_interrupted="$bold$str29$none"
           canceled="$bold""$str16 — $bold""$str13$none $str14$none... "

    replace_warning="\e[23;4H $bold""$str17 $clear_command$str18 ($keyyes/$keyno)$colon ___\e[2D$none"
   overwrite_status="\e[23;4H$bold $str10"
  overwrite_warning_site="\e[21;5H$bold$str19 ($keyyes/$keyno)$colon ___\e[2D$none"
  overwrite_warning_server="\e[21;5H$bold$str20 ($keyyes/$keyno)$colon ___\e[2D$none"

    upload_canceled="$bold$str31$none"
   uploading_status="\e[23;4H $bold$str21$none — $str22 $str28"
        downloading="$bold$str24 $site — $str23...$none"

        do_not_close="$bold$str32$none"
    download_failed="$bold$str25$none"
  download_canceled="$bold$str30$none"
  download_finished="$bold$str26$none"

#—————————————————————————————————————————————————— change to current folder

cd "${0%/*}"

#————————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————————— INSTALL SVIJA TOOLS
#————————————————————————————————————————————————————————————————————————————————

dropmsg="\e[14;4H Please drag Adobe Illustrator          \n    from \"Applications\" onto this window\n    then press return\n\n    $bold"

scriptpath='Presets.localized/§/Scripts'
templatepath='Cool Extras.localized/§'
  
if [ -d "$scriptfolder" ] && [ -d "$templatefolder" ]; then

#———————————————————————————————————————— get password

printf "$none$clear_screen"
printf "$welcome" # prints top half, bar, and svija version

# prepare for password request
printf "\e[14;5H$str35"

sudo printf "$none" # ensure password request
  
#———————————————————————————————————————— get AI path (folder OR app)
  
  printf "$clear_1523$dropmsg"
  read aipath;
  
  lastchar="${aipath: -1}"
  if [ "$lastchar" == "p" ]; then
    end=${aipath##*/}
    num=$((${#aipath} - ${#end}))-1
    aipath=${aipath:0:$num}
  fi
  
#———————————————————————————————————————— get install languages
# en_US, fr_FR · can be multiple
  
  dirlist=("$aipath/Presets.localized"/*)
  for f in "${dirlist[@]}"; do
    scriptdirs+=($(basename "$f"))
    templatedirs+=($(basename "$f"))
  done
  
#———————————————————————————————————————— create install directory strings
  
  # Scripts are always in en_US/Scripts
  for f in "${!scriptdirs[@]}"; do
    dir=${scriptdirs[f]}
    scriptdirs[$f]="${scriptpath/§/$dir}"
  done
  
  # Templates are in en_US/[only subfolder]
  for f in "${!templatedirs[@]}"; do
    dir=${templatedirs[f]}
    tempdir="${templatepath/§/$dir}"
    subfolder_array=("$aipath/$tempdir"/*)
    subfolder=($(basename "${subfolder_array[0]}"))
    templatedirs[$f]="${templatepath/§/$dir}/$subfolder"
  done
  
#———————————————————————————————————————— install scripts
  
  filelist=("Scripts"/*)
  for f in "${!filelist[@]}"; do
    for d in "${scriptdirs[@]}"; do
      src="${filelist[$f]}"
      dest=$d
      sudo cp "$src" "$aipath/$dest/"
    done
  done
  
#———————————————————————————————————————— install templates
  
  filelist=("Templates"/*)
  for f in "${!filelist[@]}"; do
    for d in "${templatedirs[@]}"; do
      src="${filelist[$f]}"
      dest=$d
      sudo cp "$src" "$aipath/$dest/"
    done
  done
  
#———————————————————————————————————————— cleanup
  
  rm -rf Scripts
  rm -fr Templates
  rm README.md

fi

#————————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————————————————————— END INSTALL SVIJA TOOLS
#————————————————————————————————————————————————————————————————————————————————

#——————————————————————————————————————————————————
#———————————————————————————————————————— variables
#——————————————————————————————————————————————————

name=''

pwd_file='.pass'

ubuntu="$user@$site::$user/SYNC"

interval=5

exclusions=(
    --exclude ".DS_Store"
    --exclude ".swp"
    --exclude ".git"
    --exclude ".command"
    --exclude ".pwd"
)


#——————————————————————————————————————————————————
#———————————————————————————————————————— functions
#——————————————————————————————————————————————————

#———————————————————————————————————————— 1 upper case

to_upper(){
    echo "$1" | tr a-z A-Z
}

#———————————————————————————————————————— 2 lower case

to_lower(){
    echo "$1" | tr A-Z a-z
}

#———————————————————————————————————————— one letter in upper case

read_one_uc(){
    read -n 1 character;
    character=$(to_upper "$character")
    echo $character
}

#———————————————————————————————————————— 3 capitalize first letter

capitalize_first(){

    firstletter=`echo $1 | cut -c1-1`
    rest=`echo $1 | cut -c2-60`

    firstletter=$(to_upper $firstletter)

    chrlen=${#rest}
    if (( chrlen > 1 )); then
        rest=$(to_lower $rest)
    else
        rest=$(to_upper $rest)
    fi

echo "$firstletter$rest"
}

#———————————————————————————————————————— 4 capitalize jean-philippe

capitalize_dash(){

    tiret="^.*\-.*$"

    if [[ "$1" =~ $tiret ]]; then
        IFS='-'
        read -ra ADDR <<< "$1"
        first=$(capitalize_first "${ADDR[0]}")
        second=$(capitalize_first "${ADDR[1]}")
        final="$first\055$second"
    else
        final=$(capitalize_first $1)
    fi
    echo $final
}

#———————————————————————————————————————— 5 capitalize space-separated words

capitalize_words(){
    words=''

    arrayName=$@
    for i in ${arrayName[@]};
        do
            i=$(capitalize_dash $i)
            words="$words$i "
        done

    # strip last character
    words=${words%?}
    echo $words
}

#———————————————————————————————————————— 6 get name prompt

prompt_for_name(){
    printf "$clear_1923"

    safe_name="^[a-zA-Z\.\ \-]{2,30}$"
    while true; do

        printf "$whats_name"
        read -p "" name

        if [[ "$name" =~ $safe_name ]]; then return 1
            else printf "$clear_status$name_error"
        fi
    done
}

#———————————————————————————————————————— 7 get name

# returns $name of person using program

#   while [[ "$flag" != 'N' ]] && [[ "$flag" != 'Q' ]] && [[ $flag != $keyup ]] && [[ $flag != $keydown ]]; do

get_current_name(){
    name=''

    # name file exists so we use it
    if [[ -f ".name" ]]; then
        name=$(<".name")
    fi

    # name file doesn't exist so we ask for name
    if [[ "$name" == '' ]] || [[ "$name" == "\n" ]]; then
        prompt_for_name
        name=$(capitalize_words $name)
        echo $name > ".name" 
        printf "$clear_status"
    fi
    printf "\e[16;0H\e[K    $bold$str05 $name$none"
}

#———————————————————— name 2.svg › name.svg

correct_svg_names(){
    sync_dirs=("SYNC"/*)
    
    for f in "${sync_dirs[@]}"; do
        all_svgs=("$f"/*.svg)
        for g in "${all_svgs[@]}"; do
    
            [[ $g =~ ^.+\s\d\.svg ]] && echo matched
    
            regexp="^.+[[:space:]][[:digit:]]\.svg"
            if [[ $g =~ $regexp ]]; then
                    new_name="${g::${#g}-6}"".svg"
                    mv "$g" "$new_name"
            fi
    
        done
    done
}

#———————————————————————————————————————— local SYNC folder exists & is not empty

sync_exists(){

    shopt -s nullglob
    dirs=( ./SYNC/*/ )
    dirs_count=${#dirs[@]}

    if (( dirs_count < 3 )); then return 1
        else return 0
    fi
}

#————————————————————— get last mod name from server

# sets $name_prev to name from /SYNC/.last on server

get_previous_name(){
    name_prev=''

    mkdir -p "SYNC" 
    echo "$name" > "SYNC/.last"

    # name file does not exist, it's probably the first run
    if [[ ! -f ".name" ]]; then                                                    
        # prepare for password request
        printf "\e[18;5H$str35"
    fi       

    # will trigger request for admin password on first run
    rsync -az --delete "${exclusions[@]}" --password-file="$pwd_file" "$ubuntu/.last" "SYNC/.last"

    name_prev=$(<"SYNC/.last")
}

#————————————————————— check if last was current user

# reset $flag if files should not be overwritten

overwrite_server(){

    if [[ $name != $name_prev ]]; then
        printf "$clear_1923 $overwrite_status $name_prev$none $overwrite_warning_server"

        confirmation=$(read_one_uc)
        if [[ $confirmation != $keyyes ]]; then
            return 1
        fi

    fi
    return 0
}

#———————————————————————————————————————— ask user what to do

# returns $flag indicating user's command

get_user_command(){
    flag=$(read_one_uc)
    
    while [[ "$flag" != 'N' ]] && [[ "$flag" != 'Q' ]] && [[ $flag != "$keyup" ]] && [[ $flag != "$keydown" ]]; do
        printf "$invalid_choice";
        flag=$(read_one_uc)
    done
}

#————————————————————————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————— program ———————————————————————————————————————————————
#————————————————————————————————————————————————————————————————————————————————————————————————
#
#   three hidden files:
#
#   .pass = rsyncd password
#   .name = first name of user
#   SYNC/.last = name of person who last worked on site

printf "$clear_screen"
printf "$welcome" # prints top half, bar, and svija version
printf "$clear_1523$site_data$clear_status"

#———————————————————————————————————————— test for write access

get_previous_name # sets $name_prev to name from /SYNC/.last on server

#———————————————————————————————————————— resume normal operations

printf "$clear_1523$site_data$instructions$clear_status"

get_current_name  # returns $name of person using program from file or prompt

echo $pass > $pwd_file; chmod 600 "$pwd_file"

#———————————————————————————————————————— main loop, ask for command, execute it

flag=''
while [[ $flag != 'Q' ]]; do

    printf "$request_command"
    get_user_command # returns $flag indicating user's command
    printf "$clear_status"

#————————————————————————————————————————————————————————————————————————————————
#———————————————————————————————————————— download
    
    if [[ $flag == $keydown ]]; then
        confirmation="$keyyes"
        if sync_exists; then # if there are files to overwrite
            if [[ $name != $name_prev ]]; then
                printf "$clear_1923 $overwrite_status $name_prev $overwrite_warning_site"
                confirmation=$(read_one_uc)
            else
                printf "$clear_1923$replace_warning";
                confirmation=$(read_one_uc)
            fi
        fi
    
        if [[ $confirmation == "$keyyes" ]]; then
            printf "$clear_status $do_not_close "
            printf "$clear_command$downloading"
            status=" $download_failed "
            rsync -az --delete "${exclusions[@]}" --password-file=$pwd_file "$ubuntu/" "SYNC" && status=" $download_finished "
        else
            status=" $download_canceled "
        fi
    fi

#———————————————————————————————————————— reset name
    
    if [[ $flag == 'N' ]]; then
        name=''; echo '' > ".name" 
        get_current_name # returns $name of person using program from file or prompt
        #printf "$clear_1523$site_data"
        status=''
    fi
    
#———————————————————————————————————————— upload
    
    if [[ $flag == $keyup ]]; then
    
        status=" $upload_canceled "
        if ! sync_exists; then # no files to synchronize
            status=" $nothing_to_upload "
    
        elif overwrite_server; then
            echo $name > "SYNC/.last"
            name_prev="$name"
            counter=0
            unset user_input
            printf "$clear_1923$uploading_status "
            printf "$clear_command\e[21;0H    " # position cursor for progress bar

            while [[ "$user_input" != ' ' ]]; do
                correct_svg_names
                char='+'
                rsync -az --delete "${exclusions[@]}" --password-file=$pwd_file "SYNC/" $ubuntu && char='❚'
                counter=$((counter+1))
                if [ $counter == "74" ]; then
                    counter=0
                    printf "\e[21;0H\e[K    "
                fi

                # clear possible errors before and after progress bar
                printf "$clear_1923$uploading_status "

                # go to line 21, right position
                pos=$((counter+4))
                printf "\e[21;$pos""H"
                printf "$char\e[K"
                IFS="" read -t $interval -n 1 user_input
            done
            status=" $uploading_interrupted "
        fi
    fi
    
#————————————————————————————————————————————————————————————————————————————————

    printf "$clear_status$status"

done # while [[ $flag != 'Q' ]]; do

osascript -e 'tell application "Terminal" to close first window' & exit

#———————————————————————————————————————— fin

