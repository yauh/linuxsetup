About
=====

These are the scripts I use to set up Debian boxes for development, testing, and sometimes even production. Find out more about [Ansible](http://ansible.cc/).

There are some older files (`bash` scripts) I used to work with in the museum. Those are no longer needed and likely to be removed at some point.

Executing the playbooks for Ansible requires ansible to be available on all machines involved. If it is, executing the playbooks is as simple as running


  * `ansible-playbook baseinstall_ansible.yml -K`
  
The -K switch asks for the sudo password.