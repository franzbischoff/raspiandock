#!/bin/bash

# turn on bash's job control
set -m

if [ -f "/etc/ssh_host_rsa_key" ]; then
  echo "SSH keys already exist."
else
  dpkg-reconfigure openssh-server
fi

service ssh start

