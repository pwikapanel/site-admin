
<!-- vim: set foldmethod=marker fmr=###,--- :-->

*Updated 21 December, 2025 · this repo contains sensitive information and must not be made public*

![Pwika: SVG-based websites built in Adobe Illustrator][logo]

[logo]: http://files.pwika.com/github/github_banner.png "Pwika: SVG-based websites built in Adobe Illustrator"

### Pwika Site Management

These files are used to create and manage accounts on a fresh server or existing server.

See [github.com/pwikapanel/server-config](https://github.com/pwikapanel/server-config) for server configuration.

Initial notes:
- an [Akamai](https://cloud.linode.com) **Nanode** can handle up to **10 accounts**
- Pwika sites are created by duplicating an existing Pwika site  
  there is no such thing as a "blank" Pwika site.

---
### Clone this Repo

On the destination server:
```
cd /opt
rm -rf site-admin
git clone ssh://git@github.com/pwikapanel/site-admin.git
chmod 777 site-admin/*.sh
```
---

<details><summary>Site Creation</summary>

### Site Creation

More than one site can be created at one time.

Installation is done from the `/opt` directory.

Each site needs to have a source `SYNC` folder in `/opt`, containing a single `JSON` file with site data.

The SYNC folders can have any name (folder names are specified in the `create.txt` file)

* * *
#### Preparing the source site `SYNC` folder

- log in to server of an existing Pwika site
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
rsync -vaPur --delete root@#sourceIP:/home/example/SYNC/ /opt/SYNC/
```
Check if there is only one json file:
```
vi -O /opt/SYNC*/*.json
```
----
#### DNS configuration

- create an `A record` for the new domain, pointing to the new server

[tech.pwika.com](https://tech.pwika.com/reference/general/custom-domain)

----
#### Make a "create.txt" file

Create passwords [here](https://files.pwika.com/passwords).

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
6. Pwika Cloud username
7. Pwika Cloud password
8. first name
9. last name
10. email address
11. time zone identifier ([list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))

For historical reasons, spaces 2 and 3 can be empty or `x`:
- the default source folder is `SYNC`
- the default home folder will be the Linux username

For example:
```
example.pwika.site:SYNC:example:example:lkdjUkdUjfleIjd:example:lkdjUkdUjfleIjd:David:Crocky:davidc@gmail.com:Europe/Paris
```
There must not be any spaces — use a hyphen in a two-word name if necessary.

To avoid missing a field, verify that there are **ten colons**.

Use multiple lines in create.txt to create multiple sites at the same time.

---
#### Clone this repo & run installation script
```
source /opt/site-admin/create.sh
```
If this will be done regularly, you can add a shortcut to `.bashrc`:
```
# master branch
alias create='cd /opt && rm -rf site-admin && git clone git@github.com:/pwikapanel/site-admin.git && source /opt/site-admin/create.sh'
```
```
# beta branch
alias create='cd /opt && rm -rf site-admin && git clone -b beta git@github.com:/pwikapanel/site-admin.git && source /opt/site-admin/create.sh'
```
----

---

</details><details><summary>Site Deletion</summary>

### Site Deletion 

### 1. Delete the DNS Records

This cannot be handled by a script.

Delete the `A` and `AAAA` DNS records at [Linode][https://cloud.linode.com/domains/]

---
### 2. Create a Delete List

On the destination server:

```
cd /opt
vi delete.txt
```
The format is:
```
url:sync ID:home folder
```
- the URL does *not* include `http://` or `https://`
- use multiple lines for multiple sites

This is a good time to make a backup of the server at [Linode][lds].

---
### 3. Delete the Accounts

```
source /opt/site-admin/delete.sh
```

---

---

</details><details><summary>Site Backup</summary>

### Site Backup

#### Backing Up Databases

For `.bashrc`:
```
alias ,bu='source /opt/site-admin/backup.sh'
```

If everything is up to date, you can just type:
```
,bu
```
Note: this means:
- recent version of `site-admin` repo
- /opt/version.txt is up to date

If not:
```
cd /opt
rm -rf site-admin
git clone ssh://git@github.com/pwikapanel/site-admin.git
chmod 777 site-admin/*.sh
vi version.txt
```
---
#### Previous Content
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
rm -rf site-admin
git clone ssh://git@github.com/pwikapanel/site-admin.git
chmod 777 site-admin/*.sh
vi site-admin/backup.sh
```
3. Run the script:
```
source site-admin/backup.sh
```
---

---

</details><details><summary>Password Reset</summary>

### Password Reset

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

</details><details><summary>Cloning a Site</summary>

### Cloning a Site

* * *
### Starting from a Clone

#### 1. Update the server label

Log in to the new server by copying the **SSH Access** from the Akamai page, then edit lines 128 & 136 of .profile:
```
,pf # edit the profile
```
----
#### 2. Update the host names

- add new DNS **A records** at Akamai · [linodes](https://cloud.linode.com/linodes) · [pwika.com](https://cloud.linode.com/domains/1515277)
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
139.122.148.232                client04.pwika.com client04
2b01:7e01::f05c:91ff:fea1:0325 client04.pwika.com client04
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

</details><details><summary>Update an Existing User</summary>

### Update an Existing User

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

</details><details><summary>Create a New User</summary>

### Create a New User

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

</details><details><summary>Utilities</summary>

### Utilities

* * *
List all groups:
```
less /etc/group
```
List all users:
```
cut -d: -f1 /etc/passwd
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

</details><details><summary>Password Issues</summary>

### Password Issues

* * *
The colon character is used by the Rsync user system to separate usernames and passwords.

Currently, a user-chosen password containing a colon **will not work**.

Some experimentation should be done to see what is possible.

For now, we accept the following characters:

    !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~£€¥

Be careful when installing websites that use these characters in their passwords.

**[MAKE BACKUPS](https://cloud.linode.com/linodes/27919822/backup)**


---

</details><details><summary>User IDs & Passwords</summary>

### User IDs & Passwords

* * *
Each Pwika account uses several user IDs and passwords:

**web site url**: self-evident.

**Ubuntu user & password**: used to configure the **rsync dæmon**
- user has permission to access the **SYNC folder** only 

**Django project name**: used for the **site folder** and **uWSGI and NGINX configuration files**

**PostgreSQL database, user & password**: used by Django to store **site data**
- password is **created randomly** when the site is created, in `[project folder]/settings.py`
- user: Django project name + 'user'
- database name: Django project name + 'db' 

**Pwika Cloud ID & password**: configured by creation script but not used by server

---

</details>

