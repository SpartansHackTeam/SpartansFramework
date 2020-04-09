#!/bin/bash
# Install script for Spartansframework
# Crated by @xer0dayz - https://spartansht.online

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

echo -e "$OKRED              __         __       $RESET"
echo -e "$OKRED            /  /     __/  /_       $RESET"
echo -e "$OKRED    _____  /  /___  /_   __/      $RESET"
echo -e "$OKRED   / ___/ /  /__  \  /  /         $RESET"
echo -e "$OKRED  (__  ) /  /  /  / /  /          $RESET"
echo -e "$OKRED /____/ /__/  /__/ /__/           $RESET"
echo -e "$OKRED                                  $RESET"
echo -e "$RESET"
echo -e "$OKORANGE + -- --=[ https://spartansht.online $RESET"
echo -e "$OKORANGE + -- --=[ Spartans Framework by @aristarkh, @n01r $RESET"
echo ""
echo -e "$OKGREEN + -- --=[ This script will install Spartansframework on Ubuntu and Debian based OS's. $RESET"
echo -e "$OKRED + -- --=[ NOTE: Installing Spartansframework on Ubuntu or Debian based OS's requires adding Kali Linux repositories to yours apt sources list. This *may* cause system instability or compatibility issues! Be sure to backup your system prior to running this script in case you need to revert. (Hit Enter to continue) $RESET"
read answer
if [[ ! -f "/etc/apt/sources.list.bak" ]]; then
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list
	echo "deb-src http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list
fi
wget https://http.kali.org/pool/main/k/kali-archive-keyring/kali-archive-keyring_2020.2_all.deb -O /tmp/kali-archive-keyring_2020.2_all.deb
apt install /tmp/kali-archive-keyring_2020.2_all.deb
apt update
cp /root/.Xauthority /root/.Xauthority.bak 2> /dev/null
cp -a /run/user/1000/gdm/Xauthority /root/.Xauthority 2> /dev/null
cp -a /home/user/.Xauthority /root/.Xauthority 2> /dev/null 
chown root /root/.Xauthority
XAUTHORITY=/root/.Xauthority
rm -Rf /tmp/spartansframework 2> /dev/null
git clone https://github.com/SpartansHackTeam/SpartansFramework /tmp/spartansframework
cd /tmp/spartansframework
bash install.sh