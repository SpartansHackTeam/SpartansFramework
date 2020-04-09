#!/bin/bash
# Uninstall script for Spartansframework
# Created by @aristarkh, @n01r - https://spartansht.online

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# VARS
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

INSTALL_DIR=/usr/share/spartansframework

echo -e "$OKGREEN + -- --=[This script will uninstall spartansframework and remove ALL files under $INSTALL_DIR. Are you sure you want to continue?$RESET"
read answer 

rm -Rf /usr/share/spartansframework/
rm -f /usr/bin/spartansframework

echo -e "$OKORANGE + -- --=[Done!$RESET"