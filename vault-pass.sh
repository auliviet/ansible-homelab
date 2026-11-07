#! /bin/sh
# Prints the Ansible vault password, read from the MacOS keycahin.
# Ansible runs this script and uses its output as the vault password. 
#   -a account name (Mac username)
#   -s the name the password was saved under
#   -w print only the password

exec security find-generic-password -a "$USER" -s ansible-vault -w