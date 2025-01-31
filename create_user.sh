#!/bin/bash

# FILE: create_user.sh
# USAGE: create_user.sh OR create_user <username> (Generated default password) OR create_user <username> <password> 
# AUTHOR: LudwigJL 
# VERSION: 1.1
# NOTES/BUGS: 
# CREATED AT: 31-01-2025
# PARAMETERS: <username> as $1 <password> as $2
# NOTES: This script streamlines the process of creating users within the linux env. This was written on an Ubuntu system.
 
sudo_check () {
	local prompt
	prompt="$(sudo -nv 2>&1)"
	if [ $? -ne 0 ] ; then	
		if echo $prompt | grep -q "^sudo"; then
			echo "This script requires sudo permissions in order to create users"
			sudo touch /var/run/system-info.pid
		else
			echo "Sorry you need sudo for this, please gain the right permissions"
			exit 1
		fi
	fi
}

prompt_user () {
	message="${1:-"Enter the account details"}"
	echo "$message"
	read -p "Enter a username: " user_name
	read -sp "Enter a password: " user_password
	echo ""
	read -sp "Enter the password again: " user_password_check
	echo ""
}

check_user () {
	grep -q \^${1}\: /etc/passwd && return 0
}

sudo_check

if [ $# -eq 0 ] ; then
	prompt_user
	while [ "$user_password" != "$user_password_check" ] ; do
		prompt_user "Passwords didn't match, re-enter the details"
		echo ""
	done
else
	user_name="$1"
	user_password="${2:-Password1}"
fi

while check_user "$user_name" ; do
	prompt_user "The username you have chosen already exists, please re-select fresh details"
done

sudo useradd -m $use -mr_name 
if [ $? -ne 0 ] ; then
	echo "Something went wrong with useradd, please try again."
	exit 2
fi

echo "$user_name:$user_password" > /tmp/passfile.txt
sudo chpasswd < /tmp/passfile.txt > /dev/null 2>&1

rm -f /tmp/passfile.txt
if [ $? -ne 0 ] ; then
	echo "WARNING: Something in the chpasswd process went wrong, for security reasons please check the /tmp and remove any passfile.txt if present"
fi	

check_user $user_name
if [ $? -ne 0 ] ; then
	echo "Failed to create user, please check the passwd file for more information"
	exit 3
fi

echo "New account successfully created"
echo -e "\nUsername: $user_name\nPassword: $user_password"
