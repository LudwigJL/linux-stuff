#!/bin/bash

# FILE: system_info.sh
# USAGE: system_info.sh
# AUTHOR: LudwigJL
# VERSION: 1.0
# NOTES/BUGS: 
# CREATED: 21-01-2025
# PARAMETER: No parameters are requried.
# NOTES: This script is aimed to simplify the process of gathering information about the running system. This involves for example: CPU usage, memory and disk usage.  
release_file=/etc/os-release

function get_sudo() {

	local prompt
	prompt=$(sudo -nv 2>&1)
	if [ $? -ne 0 ]; then
		if echo $prompt | grep -q "^sudo"; then
			echo "This script need sudo access. Enter password"
			sudo touch /var/run/system-info.pid
		else
			echo "Sorry you need sudo for this, please gain the right permissions and try again."
		fi 
	fi
}

function get_name() {

	local prompt
	prompt=$(cat /etc/*-release)
	if [ $? -ne 0 ]; then
		name="NAME=UNIDENTIFIED"
	else 
		name=$(cat /etc/*-release | grep "^NAME")
		version=$(cat /etc/*-release | grep "^VERSION_ID")
	fi

	export name
}


function available_updates() {	
	
	local prompt
	prompt=$(apt list --upgradeable 2>/dev/null | tail -n +2 | wc -l)
	
	if [ $? -ne 0 ]; then
		updates="YOU HAVE <NOT FOUND> AVALIBLE UPDATES FOR YOUR SYSTEM"
	else
		if  [ $prompt -eq 0 ]; then
			updates="\033[32mYOU HAVE NO AVAILABLE UPDATES FOR YOUR SYSTEM\033[0m"
		else
			updates="\033[31mYOU HAVE $prompt AVAILABLE UPDATES FOR YOUR SYSTEM\033[0m"
		fi

	fi

	export updates
}

function system_usage() {
	
	sys_stats=$(iostat -c | sed '1,2d' 2>/dev/null)
	
	local mem_info=$(cat /proc/meminfo)
	local mem_total_kb=$(echo "$mem_info" | grep '^MemTotal:' | awk '{print $2}')
	local mem_available_kb=$(echo "$mem_info" | grep '^MemAvailable:' | awk '{print $2}')
	
	mem_total_gb=$(echo "scale=2; $mem_total_kb / 1048576" | bc) 
	mem_available_gb=$(echo "scale=2; $mem_available_kb / 1048576" | bc)	

	export sys_stats
	export mem_total_gb
	export mem_available_gb
}

clear
get_sudo
get_name
available_updates
system_usage 
local_ip=$(hostname -I)


echo "THIS SYSTEM IS CURRENTLY RUNNING ON: $name"
echo "VERSION: $version"
echo  
echo -e "$updates"
echo
echo -e "\033[0;35mCPU INFORMATION\033[0m" 
echo "$sys_stats"
echo 
echo -e "\033[0;35mMEMORY INFORMATION\033[0m" 
echo "MEMORY TOTAL $mem_total_gb GB"
echo "MEMORY AVAILABLE $mem_available_gb GB"
echo
echo -e "\033[0;35mBASIC NETWORK INFORMATION\033[0m"
echo "LOCAL IP-ADDRESS: $local_ip"
echo
