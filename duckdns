#!/bin/bash

#######################################################################
#Setup Home Assistant on an Ubuntu Server 18.04 LTS                   #
#This script just include the basic installation                      #
#This script is written by ggmanugg                                   #
#[C] 2018 Manuel Berger                                               #
#######################################################################

#Check root
if [[ $EUID -ne 0 ]]; then
   echo This script must be run as root
   exit 1
fi

#User name
echo Enter your current user name:
read usern

#Domain name
echo Enter your duckdns domain name e.g. test.duckdns.org:
read domain

#Duckdns token
echo Enter your duckdns token:
read token

#Letsencrypt challenge 
echo Which challenge should be used? Currently http-01 and dns-01 are supported
oldIFS=$IFS
IFS=$'\n'
choices=( http-01 dns-01 )
IFS=$oldIFS
PS3="Please enter your choice: "
select answer in "${choices[@]}"; do
  for item in "${choices[@]}"; do
    if [[ $item == $answer ]]; then
      break 2
    fi
  done
done

#Prerequisites
apt-get update
apt-get upgrade -y
rm -r ~/dehydrated

#Download prerequisites
git clone https://github.com/lukas2511/dehydrated.git ~/dehydrated

#Setup dehydrated
touch ~/dehydrated/domains.txt
cat >> ~/dehydrated/domains.txt << EOF
$domain
EOF
wget https://raw.githubusercontent.com/ggmanugg/setup_server/master/hassio/config -P ~/dehydrated/
sudo sed -i -e "s/answer/$answer/g" ~/dehydrated/config

#Setup hook.sh
wget https://raw.githubusercontent.com/ggmanugg/setup_server/master/hassio/hook.sh -P ~/dehydrated/
sudo sed -i -e "s/ind/$domain/g" ~/dehydrated/hook.sh
sudo sed -i -e "s/int/$token/g" ~/dehydrated/hook.sh
sudo sed -i -e "s/usern/$usern/g" ~/dehydrated/hook.sh
sudo chmod 755 ~/dehydrated/hook.sh

#Generate certificate
cd ~/dehydrated
sudo ./dehydrated --register  --accept-terms
sudo ./dehydrated -c
