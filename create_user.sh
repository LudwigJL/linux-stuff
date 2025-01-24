#!/bin/bash 

if [ "$#" -lt 1 ]; then
	echo "You must provide the username: $0 <username>"
	exit 1
elif getent passwd "$1" ; then
	echo "The user $1 is alredy on the system"
	exit 2
fi
read -s -p "Enter a password for the new user $1: " USER_PASSWORD
sudo useradd -m "$1" 
echo "$1:$USER_PASSWORD" | sudo chpasswd

echo "User $1 has been successfully created and password set."
getent passwd "$1"









