About
=====

These are the scripts I use to set up Debian boxes for development, testing, and sometimes even production. Find out more about [Ansible](http://ansible.cc/).

Requirements
------------

* Minimal Debian install with Python and sudo

Set up ansible instances
------------------------

Set up a Debian machine with minimal installation. All required software will be taken care of by ansible. Make sure ssh connections are possible.

### Generate ssh keys on the management machine (Macbook)

User is **stephan**

```
macbook: stephan$ ssh-keygen -t rsa
macbook: stephan$ ssh-keygen -t dsa
```

### Set up ssh connection to remote machine (10.211.55.4)

Setting up the remote machine so you can easily log in using ssh is done using the init playbook.

Add the remote host to your known hosts by connecting once via ssh:

```macbook: stephan$ ssh root@10.211.55.4```


On Mac OS X you need to make sure that sshpass is installed.

```macbook: stephan$ brew install https://raw.github.com/eugeneoden/homebrew/eca9de1/Library/Formula/sshpass.rb```

If you execute the init script it also creates a new user called ansible, so make sure you adjust the password to something sensible.

Take the hash for your password from the output of

``` openssl passwd -salt $1$SomeSalt$ -1 password```

Execute the init playbook:

```macbook: stephan$ ansible-playbook init.yml -i ./hosts -k```


Check if it works:

```macbook: stephan$ ssh ansible@10.211.55.4``

## Set up ansible to manage remote machine

First, install ansible on your machine (OS X) by using something like [HomeBrew](http://brew.sh/):

```
macbook: stephan$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
macbook: stephan$ brew install ansible
```

Add host to ``hosts``:

```
[parallels]
10.211.55.4
```

Executing Playbooks
-------------------

Executing the playbooks for Ansible requires ansible to be available on all machines involved. If it is, executing the playbooks is as simple as running (`-K` is only required when password needs to be supplied for executing sudo)

  * `ansible-playbook baseinstall_ansible.yml -i ./hosts --ask-pass`
  
The -K switch asks for the sudo password.

  * `ansible-playbook baseinstall_ansible.yml -i ./hosts -K --tags "common,dev,mail,web"`

Individual steps can be (de-)activated by explicitly calling certain tags using the `--tags` switch.


Playbooks (tags)
---------
### common
* Installs some common packages
* setting the timezone based on an ansible variable

### update
* `apt-get update`

### devtools
* installs some development packages

### gmailrelay
* sets up exim4 to send emails using Google Mail

### munin
* Server monitoring using munin is set up
* requires nginx

### webserver
* sets up nginx as the webserver

### php5
* enables nginx to serve php pages

### mysql
* to be done