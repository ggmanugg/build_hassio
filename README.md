
# Install Home Assistant

One command to install Home Assistant on an Ubuntu Server 18.04 LTS

Just setup the server without configurations

You can access it under http://ipaddress:8123

## Requirements

```
wget
python3-pip 
python3-venv
homeassistant
wheel
```

## Run

Run as root:

```bash
wget https://raw.githubusercontent.com/ggmanugg/setup_server/master/hassio/install.sh
sudo bash ./install.sh
```

## Supported Machine types

- Ubuntu Server 18.04 LTS
