---
title: "Ansible First Steps"
date: 2020-07-17T17:33:00-07:00
draft: false
tags: ["Fun","Learning","Business"]
---

Quick little blurb for today, but I was able to create my first ansible playbook and in scale (my small environment of 4 linux VMs) update all my servers via apt! I have ansible running on MacOS which made the various guide online of how to get it up and running a little off, but I was able to figure it out!

Biggest ah ha moment for me was that on MacOS the ansible directory (installed via brew) was in my home directory "/home/tyler/.ansible". I then just made a very basic ansible.cfg file. 

##### ansible.cfg

```
[defaults]
inventory       = <path to inven file>/inven
```

##### inventory file
```
[debianvms]
192.168.1.11
192.168.1.12
192.168.1.13
192.168.1.14
```

##### playbook

```yaml
- hosts: debianvms
  become: true
  tasks:
    - name: Run apt-get update
      apt: update_cache=yes force_apt_get=yes

    - name: Upgrade all packages on servers
      apt: upgrade=dist force_apt_get=yes

    - name: Check if a reboot is required
      register: reboot_required_file
      stat: path=/var/run/reboot-required get_md5=no
```

[Ansible Playbook (Download)](/files/aptupdate.yml)

Then to run the playbook you just run the command, the --ask-become-pass is so it prompts me to enter the SUDO password as it's needed to run the apt update and upgrade.

##### Running the playbook

```bash
ansible-playbook playbook.yml --ask-become-pass
```
