#!/bin/bash

: ' 

DOC

This update script supports Arch, CentOS and Debian based systems. The logs are redirected to either /var/log/updater.log (Success) or /var/log/updater_errors.log (Error)

Please make sure to run the script as sudo
' 

release_file=/etc/os-release
logfile=/var/log/updater.log
errorlog=/var/log/updater_errors.log

echo 'Update started, this may take up to a minute to finish...'

if grep -q "Arch" $release_file
then
	#The host is based on Arch
	echo 'Arch-based host identified. Performing system update...'
	sudo pacman -Syu 1>>$logfile 2>>$errorlog

	if [ $? -ne 0 ]
	then
		echo "An error occured, please check the $errorlog file."
		exit 1
	else 
		echo "Arch system updated successfully"
	fi	
fi

if grep -q -i "CentOS" $release_file 
then
	#Host is based on CentOS
	echo 'CentOS-based host identified. Perfoming system update...'
	sudo yum update -y 1>>$logfile 2>>$errorlog
	if [ $? -ne 0 ]
	then 
		echo "An error occured, please check the $errorlog file."
		exit 2
	else 
		echo "CentOS system updated successfully"
	fi
fi

if grep -qi "Ubuntu" $release_file || grep "Debian" $release_file
then
	# Host is Debian based 
	echo 'Debian-based (Debian/Ubuntu) host identified. Performing system update...'
	sudo apt update 1>>$logfile 2>>$errorlog
	if [ $? -ne 0 ]
	then
		echo "An error occured, please check the $errorlog file."
		exit 3
	else
		echo "Package list update for Debian-based system completed successfully" 
	fi
	
	sudo apt dist-upgrade -y 1>>$logfile 2>>$errorlog
	if [ $? -ne 0 ]
	then
		echo "An error occured, please check the $errorlog file."
		exit 4
	else
		echo "System upgrade for Debian-based system completed successfully."
	fi
fi


if grep -qi "Fedora" $release_file
then
	echo "Fedora-based host identified. Performing system update..."
	sudo dnf update -y 1>>$logfile 2>>$errorlog
	if [ $? -ne 0 ]
	then
		echo "An error occured, please check the $errorlog file."
		exit 5
	else
		echo "Package list update for Fedora-based system completed successfully."
	fi

	sudo dnf upgrade -y 1>>$logfile 2>>$errorlog
	if [ $? -ne 0 ]
	then
		echo "An error occured, please check the $errorlog file."
		exit 6
	else
		echo "System upgrade for Fedora-based system completed successfully."
	fi
	 
fi
