
# Install Home Assistant

One command to install Home Assistant on an Ubuntu Server 18.04 LTS with Duck DNS and Let's Encrypt

You can access it under https://ipaddress:8123

The certificates will be renewed automatically and the duckdns entry will be adjusted continuously

## Requirements

```
bash
git
python3-pip 
python3-venv
homeassistant
wheel
```

## Run

Run as root:

```bash
git clone https://github.com/ggmanugg/build_hassio.git
bash build_hassio/install.sh
```

## Supported Machine types

- Ubuntu Server 18.04 LTS
