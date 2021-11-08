#!/bin/bash

spinner () {
	PID=$!
	i=1
	delay=0.5
	sp="|/-\\"
	echo -n ' '
	while [ -d /proc/$PID ]; do
        	temp=${sp#?}
        	printf " [%c] " "$sp"
        	sp=$temp${sp%"$temp"}
        	sleep $delay
        	printf "\b\b\b\b\b${sp:i++%${#sp}:0}"
	done
	printf "\b\b\b\b\b\b"
}

### Installig necessary packages ###
CHECK_OS=$(cat /etc/*elease* | grep "^NAME" | cut -d "\"" -f2)

if [ "$CHECK_OS" == "Debian" ] ; then
	echo -e "\n==========> Installing Packages <==========\n"
	apt-get update -y && apt-get install -y nmap net-tools ipcalc xsltproc vim
	elif [ "$CHECK_OS" == "Ubuntu" ] ; then
		echo -e "\n==========> Installing Packages <==========\n"
		apt-get update -y && apt-get install -y nmap net-tools ipcalc xsltproc vim
	elif [ "$CHECK_OS" == "CentOS" ] ; then
		echo -e "\n==========> Installing Packages <==========\n"
		yum check-update && yum install -y nmap net-tools ipcalc xsltproc vim
else
	echo "Sorry, the Operating System is not compatible!"
	exit 0
fi

### Detecting Network ###
NETWORK=$(for i in `ifconfig | grep broadcast | awk '{print $2,$4}' | sed -e 's/ /\//g'`; do ipcalc "$i" | grep Network | awk '{print $2}'; done)

### Verifying hosts on the network ###
echo -e "\n==========> Checking online hosts on the network <==========\n"
nmap -sn "$NETWORK" > online_hosts &
spinner

### Verifying active services ###
echo -e "\n==========> Checking online services <==========\n"
for host in `cat online_hosts | grep "Nmap scan report" | awk '{print $5}'`; do nmap -sT "$host" -oX nmap_report.xml 1>/dev/null; done &
spinner

### Creating report ###
echo -e "\n==========> Creating Report File <==========\n"
xsltproc nmap_report.xml -o nmap_report.html
echo -e "\n==========> Removing temporary files <==========\n"
rm nmap_report.xml && rm online_hosts
echo -e "\n==========> Scan Complete <=========="
echo -e "Open nmap_report.html file to see the complete report"
