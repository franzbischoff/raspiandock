#!/bin/bash

if [ -f "/etc/ssh_host_rsa_key" ]; then
  echo "SSH keys already exist."
else
  dpkg-reconfigure openssh-server
fi
