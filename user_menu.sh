#!/bin/bash

# FILE: create_user.sh
# USAGE: create_user.sh OR create_user <username> (Generated default password) OR create_user <username> <password> 
# AUTHOR: LudwigJL 
# VERSION: 1.2
# NOTES/BUGS: 
# CREATED AT: 31-01-2025
# PARAMETERS: <username> as $1 <password> as $2
# NOTES: This script streamlines the process of creating users within the linux env. This was written on an Ubuntu system.

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

create_user () {
	prompt_user "Enter new user account details"
	while check_user "$user_name" ; do
		prompt_user "The username you have chosen already exists, please re-select fresh details"
	done
	while [ "$user_password" != "$user_password_check" ] ; do
		prompt_user "Passwords didn't match, re-enter the details"
		echo ""
	done

	sudo useradd -m "$user_name"
	echo "${user_name}:$user_password" | sudo chpasswd
	echo "$user_name created"
}

delete_user () {
	read -p "Enter user to delete: " user_name
	while ! check_user "$user_name" ; do
		echo "User not found"
		return 1
	done
	sudo userdel -r $user_name
	echo "$user_name deleted"
}


while true ; do 
	clear 
	echo "user management"
	echo "1: Create User"
	echo "2: Delete User"
	echo "3: Exit"
	read -sn1
	case "$REPLY" in
		1) create_user;;
		2) delete_user;;
		3) exit 0;;
	esac
	read -n1 -p "Press any key"
done


