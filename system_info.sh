#!/bin/bash

# FILE: system_info.sh
# USAGE: system_info.sh
# AUTHOR: LudwigJL
# VERSION: 1.1
# NOTES/BUGS: 
# CREATED: 21-01-2025
# PARAMETER: No parameters are required.
# NOTES: This script is aimed to simplify the process of gathering information about your debian-based system.  

function calculate_memory() {
	local mem_total_kb=$(cat "$memory_file" | grep '^MemTotal:' | awk '{print $2}')
	local mem_available_kb=$(cat "$memory_file" | grep '^MemAvailable:' | awk '{print $2}')
	
	mem_total_gb=$(echo "scale=2; $mem_total_kb / 1048576" | bc) 
	mem_available_gb=$(echo "scale=2; $mem_available_kb / 1048576" | bc)	
}

release_file=/etc/os-release
memory_file=/proc/meminfo

name=$(grep "^NAME" $release_file | cut -d'=' -f2)
version=$(grep "^VERSION_ID" $release_file | cut -d'=' -f2)
if [ -z "$name" ]; then
	name="NAME=UNIDENTIFIED"
fi

if [ -z "$version" ]; then
	version="VERSION=UNIDENTIFIED"
fi

available_updates=$(apt list --upgradeable 2>/dev/null | tail -n +2 | wc -l)
if [ $? -ne 0 ]; then
	updates="UNABLE TO RETRIEVE UPDATE INFORMATION"
else
	if [ $available_updates -eq 0 ]; then
		updates="\033[32mYOU HAVE NO AVAILABLE UPDATES FOR YOUR SYSTEM\033[0m"
	else
		updates="\033[31mYOU HAVE $available_updates AVAILABLE UPDATES FOR YOUR SYSTEM\033[0m"
	fi
fi

sys_stats=$(iostat -c | sed '1,2d' 2>/dev/null)
if [ $? -ne 0 ]; then
	sys_stats="UNABLE TO RETRIEVE CPU INFORMATION"
fi

if [ ! -f "$memory_file" ]; then
	mem_total_gb="UNABLE TO RETRIEVE MEMORY INFORMATION"
	mem_available_gb="UNABLE TO RETRIEVE MEMORY INFORMATION"
else
	calculate_memory
fi

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
