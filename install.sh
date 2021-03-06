#!/bin/bash

#######################################################################
#Setup Home Assistant on an Ubuntu Server 18.04 LTS                   #
#This script just include the basic installation                      #
#This script is written by ggmanugg                                   #
#[C] 2018 Manuel Berger                                               #
#######################################################################

#User name
echo Enter your current username:
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

#UptoDate
sudo apt-get update
sudo apt-get upgrade -y

#Install prerequisites
sudo apt-get install python3-pip python3-venv -y

#Setup virtual environment
python3 -m venv homeassistant

source /home/"$usern"/homeassistant/bin/activate
python3 -m pip install wheel

#Install Home Assistant
python3 -m pip install homeassistant

#Setup hass service
source /home/"$usern"/homeassistant/bin/activate && hasslocation=$(echo $(whereis hass)|awk '{print $2}')

sudo bash -c 'rm /etc/systemd/system/homeassistant@'"$usern"'.service'
sudo bash -c 'touch /etc/systemd/system/homeassistant@'"$usern"'.service'
sudo bash -c 'cat >> /etc/systemd/system/homeassistant@'"$usern"'.service <<EOF
[Unit]
Description=Home Assistant
After=network-online.target
[Service]
Type=simple
User=%i
ExecStart='"$hasslocation"' -c '/home/$usern/.homeassistant'
[Install]
WantedBy=multi-user.target
EOF'

sudo bash -c 'systemctl daemon-reload'
sudo bash -c 'systemctl enable homeassistant@'"$usern"'.service'
sudo bash -c 'systemctl start homeassistant@'"$usern"'.service'

#Begin duckdns letsencrypt

#Prerequisites
sudo rm -r /home/"$usern"/dehydrated

#Download prerequisites
git clone https://github.com/lukas2511/dehydrated.git /home/"$usern"/dehydrated

#Setup dehydrated
touch /home/"$usern"/dehydrated/domains.txt
cat >> /home/"$usern"/dehydrated/domains.txt << EOF
$domain
EOF
cp /home/"$usern"/build_hassio/config /home/"$usern"/dehydrated/
sudo sed -i -e "s/answer/$answer/g" /home/"$usern"/dehydrated/config

#Setup hook.sh
cp /home/"$usern"/build_hassio/hook.sh /home/"$usern"/dehydrated/
sudo sed -i -e "s/ind/$domain/g" /home/"$usern"/dehydrated/hook.sh
sudo sed -i -e "s/int/$token/g" /home/"$usern"/dehydrated/hook.sh
sudo sed -i -e "s/usern/$usern/g" /home/"$usern"/dehydrated/hook.sh
chmod 755 /home/"$usern"/dehydrated/hook.sh

#Generate certificate
cd /home/"$usern"/dehydrated
./dehydrated --register  --accept-terms
./dehydrated -c

#Add certificate to home assistant
cert=$(echo $(sudo find /home/admin/dehydrated/certs/ -name "fullchain.pem"))
key=$(echo $(sudo find /home/admin/dehydrated/certs/ -name "privkey.pem*"))

sed -i '/^http\:/a \ \ base_url\: '"$domain"':8123' /home/"$usern"/.homeassistant/configuration.yaml
sed -i '/^http\:/a \ \ ssl_certificate\: '"$cert"'' /home/"$usern"/.homeassistant/configuration.yaml
sed -i '/^http\:/a \ \ ssl_key\: '"$key"'' /home/"$usern"/.homeassistant/configuration.yaml

#Restart home assistant
sudo bash -c 'sudo systemctl restart homeassistant@'"$usern"'.service'

#Setup duckdns cron
rm -r /home/"$usern"/duckdns
mkdir /home/"$usern"/duckdns
subd=$(echo $domain | sed 's/[.].*$//')
touch /home/"$usern"/duckdns/duck.sh
cat >> /home/"$usern"/duckdns/duck.sh << EOF
echo url="https://www.duckdns.org/update?domains=$subd&token=$token&ip=" | curl -k -o /home/"$usern"/duckdns/duck.log -K -
EOF
chmod 700 /home/"$usern"/duckdns/duck.sh
sudo /home/"$usern"/duckdns/duck.sh

#Add crontabs
crontab -l > mycron
echo "0 1 1 * * /home/$usern/dehydrated/dehydrated -c" >> mycron
crontab mycron
rm mycron

crontab -l > mycron
echo "*/5 * * * * /home/"$usern"/duckdns/duck.sh >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron

#Clean up
clear
cat << "EOF"
  _____ ___ _   _ ___ ____  _   _ 
 |  ___|_ _| \ | |_ _/ ___|| | | |
 | |_   | ||  \| || |\___ \| |_| |
 |  _|  | || |\  || | ___) |  _  |
 |_|   |___|_| \_|___|____/|_| |_|    
EOF
echo -e '\n'
echo Go to https://ipaddress:8123 and enjoy your Home Assistant
