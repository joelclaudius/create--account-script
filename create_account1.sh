#!/bin/bash
# Step 1: Getting information
echo "Please provide the following information for the new user."
echo "First Name: "
read fname
echo "Last Name: "
read lname
echo "Email Address: "
read email
echo "username: "
read username
# Step 2: Attempting to create the user account and check for success or failure
# Using the adduser command with flags to disable password and add user information
adduser --disabled-password --gecos "$fname $lname $email" $username
if [ $? -eq 0 ]; then
    echo "User account for ${fname} ${lname} created successfully."
else
    echo "Failed to create user account, exit status'$?'."
    exit 1
fi

# Step 3: Generate a random password
# Generating a random passphrase for the SSH key
passphrase=$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?/\' < /dev/urandom | head -c 32)

# Step 4: Generate a message for the user
# Storing the passphrase and username in a directory located in the pwd
mkdir -p $username
echo "Username: $username" > $username/account_info.txt
echo "Password: $passphrase" >> $username/account_info.txt

# Step 5: Generate RSA keys, and check for errors
# Generating RSA keys with the specified passphrase
ssh-keygen -t rsa -b 4096 -f $username/id_rsa -N "$passphrase" -q
if [ $? -eq 0 ]; then
    echo "Successiful generated keys"
else
    echo "Failed to generate SSH keys."
    exit 2
fi

# Step 6: Move the public key to the appropriate location
# Checking if the .ssh directory exists, creating it if not
if [ ! -d "/home/$username/.ssh" ]; then
    mkdir -p /home/$username/.ssh
    chown $username:$username /home/$username/.ssh
    chmod 70 /home/$username/.ssh
fi
# Moving the public key to the user's .ssh/authorized_keys file
mv $username/id_rsa.pub /home/$username/.ssh/authorized_keys
chown $username:$username /home/$username/.ssh/authorized_keys
chmod 60 /home/$username/.ssh/authorized_keys
echo "All tasks done successifully"

