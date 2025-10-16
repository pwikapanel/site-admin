
<!-- vim: set foldmethod=marker fmr=###,--- :-->

*Updated 16 October, 2025 · this repo contains sensitive information and must not be made public*

![Svija: SVG-based websites built in Adobe Illustrator][logo]

[logo]: http://files.svija.love/github/readme-logo.png "Svija: SVG-based websites built in Adobe Illustrator"

# remember to remove beta from installer below when this becomes the main branch

<details><summary>add in when done</summary><br>

- dns-mgmt directory of this repo contains an Akamai token for Svija
- various files contain links to Google documents with passwords

    need uwsgi & rsyncd log rotation

    using different django ID & home folder needs testing

- accents in names must be removed from create.txt
- numbered subdomains require different home folder

* * * * *

`delete.sh` threw an error:
```
deleting deb2.svija.com
  └── site folder exists

Removing group `deb2' ...
Done.

  ├── ubuntu group deb2 deleted

Removing crontab ...
Removing user `deb2' ...
userdel: user deb2 is currently used by process 1044
deluser: `/usr/sbin/userdel deb2' returned error code 8. Exiting.

  ┌── ubuntu user deb2 deleted
  ├── /home/deb2 deleted
  ├── nginx configs deleted
  ├── uwsgi config deleted
  ├── certbot configs deleted
  ├── rsyncd.scrt updated
  └── rsyncd.conf updated

DROP DATABASE
psql:<stdin>:1: ERROR:  role "deb2user" cannot be dropped because some objects depend on it
DETAIL:  owner of schema public
```
* * * * *
</details>

### Svija Site Management

These files are used to create and manage accounts on a fresh server or existing server.

See [github.com/svijasvg/server](https://github.com/svijasvg/server) for server configuration.

Initial notes:
- an [Akamai](https://cloud.linode.com) **Nanode** can handle up to **10 accounts**
- Svija sites are created by duplicating an existing Svija site  
  there is no such thing as a "blank" Svija site.

---

### Site Creation

<details><summary>expand</summary><br>

More than one site can be created at one time.

Installation is done from the `/opt` directory.

Each site needs to have a source `SYNC` folder in `/opt`, containing a single `JSON` file with site data.

The SYNC folders can have any name (folder names are specified in the `create.txt` file)

* * *
#### Preparing the source site `SYNC` folder

- log in to server of an existing Svija site
- navigate to `/home/example`
- `workon djangoEnv`
- `rm SYNC/*.json`
- `./manage.py dumpdata > SYNC/[date]-[version].json`

----
#### Getting the SYNC folder

- log in to new site server
- add SSH key to source server
```
ssh-copy-id root@000.000.000.000 # IP address of source server
```
```
rsync -vaPur --delete #sourceIP:/home/example/SYNC/ /opt/SYNC/
```
Check if there is only one json file:
```
vi -O /opt/SYNC*/*.json
```
----
#### DNS configuration

- create an `A record` for the new domain, pointing to the new server

[tech.svija.com](https://tech.svija.com/reference/general/custom-domain)

----
#### Make a "create.txt" file

Create passwords [here](https://files.svija.com/passwords).

```
cd /opt
vi create.txt
```
Each line should be a **colon separated list** containing:
1. url
2. source SYNC folder
3. home folder
4. Linux username
5. Linux password
6. Svija Cloud username
7. Svija Cloud password
8. first name
9. last name
10. email address
11. time zone identifier ([list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))

For historical reasons, spaces 2 and 3 can be empty or `x`:
- the default source folder is `SYNC`
- the default home folder will be the Linux username

For example:
```
example.svija.site:SYNC:example:example:lkdjUkdUjfleIjd:example:lkdjUkdUjfleIjd:David:Crocky:davidc@gmail.com:Europe/Paris
```
There must not be any spaces — use a hyphen in a two-word name if necessary.

To avoid missing a field, verify that there are **ten colons**.

Use multiple lines in create.txt to create multiple sites at the same time.

---
#### Clone this repo & run installation script

On the destination server:
```
cd /opt
rm -rf admin
# git clone ssh://git@github.com/svijasvg/admin.git
git clone -b pwika ssh://git@github.com/svijasvg/admin.git # pwika branch
rm -rf admin/base\ site                                   # if not needed
chmod 777 admin/*.sh
```
```
source /opt/admin/create.sh
```
If this will be done regularly, you can add a shortcut to `.bashrc`:
```
# master branch
alias create='cd /opt && rm -rf admin && git clone git@github.com:/svijasvg/admin.git && source /opt/admin/create.sh'
```
```
# beta branch
alias create='cd /opt && rm -rf admin && git clone -b beta git@github.com:/svijasvg/admin.git && source /opt/admin/create.sh'
```
----

---
</details>

### backup.md

<details><summary>expand</summary>

* * *
### Backing Up Databases

For `.bashrc`:
```
alias ,bu='source /opt/admin/backup.sh'
```

If everything is up to date, you can just type:
```
,bu
```
Note: this means:
- recent version of admin repo
- /opt/version.txt is up to date

If not:
```
cd /opt
rm -rf admin
git clone ssh://git@github.com/svijasvg/admin.git
chmod 777 admin/*.sh
vi version.txt
```
---
### Previous Content
Note that this script only backs up active sites. Sleeping sites are not backed up (although it might be fine).

1. Update `sitelist.txt` with project folders (not URL's):
```
ls /home
cd /opt
```
```
vi sitelist.txt
```
2. Clone the git repository, and set date & version:
```
cd /opt
rm -rf admin
git clone ssh://git@github.com/svijasvg/admin.git
chmod 777 admin/*.sh
vi admin/backup.sh
```
3. Run the script:
```
source admin/backup.sh
```
---

---
</details>

### passwords.md

<details><summary>expand</summary>

* * *
### Resetting A Password

---
### From the Support Account

The easiest way is to connect to the user's website using the `support` username:
- navigate to Home › **Users**
- click on the affected user's **username**
- click on the (tiny) text "you can change the password using this form"

---
### From the Command Line

1. log in to the user's server
2. change to the user's home folder
3. start the Virtual Environment:
```
workon djangoEnv
```
4. change the password:
```
./manage.py changepassword #username
```
---

---
</details>

### cloning.md

<details><summary>expand</summary>

* * *
### Starting from a Clone

#### 1. Update the server label

Log in to the new server by copying the **SSH Access** from the Akamai page, then edit lines 128 & 136 of .profile:
```
,pf # edit the profile
```
----
#### 2. Update the host names

- add new DNS **A records** at Akamai · [linodes](https://cloud.linode.com/linodes) · [svija.love](https://cloud.linode.com/domains/1515277)
- set server host names
```
hostnamectl set-hostname #SUBDOMAIN
```
Replace the source subdomain and IP addresses with the new subdomain:
```
vi /etc/hosts
```
This is the part to be modified:
```
139.122.148.232                client04.svija.love client04
2b01:7e01::f05c:91ff:fea1:0325 client04.svija.love client04
```
Reboot the server:
```
reboot
```
When you see `Connection to 143.42.194.159 closed.`, copy the IP address then type:
```
ping #IP address
```
As long as you see **request timeout** the server has not completed rebooting.

----

### Server is Done

The server is now ready to host new accounts.

If the source image backup might be replaced, then this is a good time to make a backup called **source image** for the next server.
---
---


---
</details>

### delete.md

<details><summary>expand</summary>

* * *
**NOTE**: it was necessary to delete the group "shadow" to reinstall it.

    delgroup shadow

### Deleting Svija Websites

[manual instructions](https://github.com/svijasvg/knowledge/blob/master/delete-user.md)

---
### 1. Delete the DNS Records

This cannot be handled by a script.

Configure the [DNS records][ld] at [Linode][lds]

[ld]: https://cloud.linode.com/domains/
[lds]: https://cloud.linode.com/linodes/

---
### 2. Create a Delete List

```
cd /opt
vi delete.txt
```
The format is:
```
i
url:sync ID:home folder
```
- use multiple lines for multiple sites

This is a good time to make a backup of the server at [Linode][lds].

---
### 3. Delete the Accounts

On the destination server:

```
cd /opt
rm -rf admin
git clone -b beta ssh://git@github.com/svijasvg/admin.git
chmod 777 admin/*.sh
source /opt/admin/delete.sh
```

---
### 5. Update Spreadsheets

Update the [client spreadsheet][cs] or [Svija spreadsheet][ss].

Use **cmd-shift-X** to strike-through deleted sights, and change the text color to the gray over the red square.

[cs]: https://docs.google.com/spreadsheets/d/1yz3OETWWM-lpTyubIba8ptQf7MJV6ft38_yTNd0MGcg/edit#gid=1287837631
[ss]: https://docs.google.com/spreadsheets/d/1kZYUpenHkvHLGCyQgu5RaOrrRiOUIHVx4bQcugrhJQI/edit#gid=0
---


---
</details>

### FTP User Setup

<details><summary>expand</summary>

* * *
FTP users need to be able to access their home directories, but shouldn't be able to see other users' content.

The setup described below:
- sets the users home directory to `/home/username`
- allows them to *read* everything in that directory
- allows them to modifiy everything in `/home/username/SYNC`

[Source article](https://www.techrepublic.com/article/how-to-use-sftp-with-a-chroot-jail/)


delete extra users & groups


---
</details>

### Server Configuration

<details><summary>expand</summary>

* * *
Make `root` the owner of the home directory:
```
chown root /home
```
[reference](https://linux.die.net/man/5/sshd_config)

Add the new group:
```
groupadd restricted
```
Update the SSHD config file:
```
vi /etc/ssh/sshd_config
```
Update line 115:
```
#Subsystem sftp /usr/lib/openssh/sftp-server
Subsystem sftp internal-sftp
```
At the bottom, add:
```
Match Group restricted
ChrootDirectory %h
ForceCommand internal-sftp
AllowTcpForwarding no
X11Forwarding no
```

---
</details>

### Update an Existing User

<details><summary>expand</summary>

* * *
Create a password for each user:
```
passwd [username]
```

Copy the following to TextEdit, and replace `xxx` with the new username, then paste in Terminal:
```
usermod -d /home/xxx xxx                #1
usermod -s /bin/false xxx               #2
usermod -g restricted xxx               #3
chown -R root: /home/xxx                #4
chmod -R 755 /home/xxx
chmod -R 755 /home/xxx/SYNC             #5
chown -R xxx:restricted /home/xxx/SYNC
```
1. change a user's home directory
2. sets the shell to `/bin/false` (so no shell access)
3. adds user to group `restricted`
4. prevent user from modifying files, by making `root` the owner
5. allow user to modify the `SYNC` folder

Restart SSHD:
```
systemctl restart sshd
```

---
</details>

### Create a New User:

<details><summary>expand</summary>

* * *
```
useradd -g restricted -s /bin/false -m -d /home/USER USER
passwd USER   # guizmo
```
`useradd` flags:
- `-g restricted` · set the user's group
- `-s /bin/false` · set shell to prevent SSH access
- `-m` · create the user's home directory
- `-d /home/USER` · set the user's home directory

Block user access to their home directory:
```
chown root: /home/USER
chmod 755 /home/USER
```
Create & authorize the SYNC folder:
```
mkdir /home/USER/SYNC   # CHECK PERMISSIONS BEFORE CONTINUING
chmod -R 755 /home/USER/SYNC
chown -R USER:restricted /home/USER/SYNC
```
Restart SSHD:
```
systemctl restart sshd
```
---
</details>

### Utilities

<details><summary>expand</summary>

* * *
List all groups:
```
less /etc/group
```
Get a users groups by typing:
```
groups USERNAME
```
Get a user's home directory by typing:
```
getent passwd USERNAME
```
Delete a group:
```
groupdel GROUPNAME
```
---
</details>

### Password Issues

<details><summary>expand</summary>

* * *
The colon character is used by the Rsync user system to separate usernames and passwords.

Currently, a user-chosen password containing a colon **will not work**.

Some experimentation should be done to see what is possible.

For now, we accept the following characters:

    !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~£€¥

Be careful when installing websites that use these characters in their passwords.

**[MAKE BACKUPS](https://cloud.linode.com/linodes/27919822/backup)**


---
</details>

### User IDs & Passwords

<details><summary>expand</summary>

* * *
Each Svija account uses several user IDs and passwords:

**web site url**: self-evident.

**Ubuntu user & password**: used to configure the **rsync dæmon**
- user has permission to access the **SYNC folder** only 

**Django project name**: used for the **site folder** and **uWSGI and NGINX configuration files**

**PostgreSQL database, user & password**: used by Django to store **site data**
- password is **created randomly** when the site is created, in `[project folder]/settings.py`
- user: Django project name + 'user'
- database name: Django project name + 'db' 

**Svija Cloud ID & password**: configured by creation script but not used by server

---
</details>

### Updating to a New Version

<details><summary>expand</summary>

* * *
1. Change Branch Specifications & Commit

In the beta branch:
```
cd ~/Documents/admin
vi -O create.sh delete.sh
```
In vim:
```
:windo %s/-b beta/-b master/g
```
Commit:
```
git commit -m "last commit before merge" -a && git push -u
```
---
2. Merge to Master

Check out the **destination branch** and merge ([list of commits](https://github.com/svijasvg/admin/commits/beta)):
```
git checkout master
git merge beta --no-ff
```
Push the new version:
```
git push origin master
```
---
3. Create A New Github Release

On Github, create a [new release](https://github.com/svijasvg/admin/releases) from the **master branch**.

- use the current version number for the tag (1.0.1)
- choose target **Master**
- use the month & year for the title (October 2021)
- if there is more than one release in a month, append -1, -2 etc. to all releases for the month
- use the [commit list](https://github.com/svijasvg/admin/commits/master) for the description

---
4. Check Out the Beta Branch

Commit any changes, then check out the beta branch:
```
git status
git commit -m "last commit before going back to beta" -a
```
Commit any changes, then check out the beta branch:
```
git checkout beta 
git merge master --no-ff -m "starting new version"
git push -u
```
---
5. Update Branches & Increment the Version Number

In same repository as this document:
```
cd ~/Documents/admin
vi -O README.md create.sh delete.sh
```
In vim:
```
:windo %s/1.0.1/1.0.1/g
```
Then the branch specifications:
```
vi -O create.sh delete.sh
```
In vim:
```
:windo %s/-b master/-b beta/g
```
Commit the changes:
```
git commit -m "updated version number" -a && git push -u  
```

---
</details>

