#!/bin/bash
echo "User account to be removed"
read username
deluser $username
rm -r /home/$username
rm -r ./$username
