About
=====

These are the scripts I use to set up Debian boxes for development, testing, and sometimes even production. Find out more about [Ansible](http://ansible.cc/).

Requirements
------------

* `apt-get install sudo
* user added to sudoers file

Playbooks
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

### timemachine


Executing Playbooks
-------------------

Executing the playbooks for Ansible requires ansible to be available on all machines involved. If it is, executing the playbooks is as simple as running


  * `ansible-playbook baseinstall_ansible.yml -K`
  
The -K switch asks for the sudo password.

  * `ansible-playbook baseinstall_ansible.yml -K --tags "common,dev,mail,web"`

Individual steps can be (de-)activated by explicitly calling certain tags using the `--tags` switch.

Museum
------
There are some older files (`bash` scripts) I used to work with in the museum. Those are no longer needed and likely to be removed at some point.