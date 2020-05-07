[WORK IN PROGRESS]

# OpenVPN server in docker complete with an EasyRSA PKI CA.

Container was initially tagged from mjenz/rpi-openvpn, which in turn is kylemanna/docker-openvpn with an armhf base image.

This source was forked in order to be used in a kodi add-on to allow easy vpn implementation in closed systems like LibreELEC.

The docker container: rpi-openvpn

The git repository: nvdias0/rpi-dockeropenvpn

The git repository for the kodi add-on: nvdias0/rpi-kodi-openvpn


## QUICK START

Pick a name for the $OVPN_DATA data volume container. It's recommended to use the ovpn-data- prefix to operate seamlessly with the reference systemd service. Users are encourage to replace example with a descriptive name of their choosing.
``` OVPN_DATA="ovpn-data-example" ```

Pick a name for $OVPN_SERVER Usually the dns server name or WAN ip address that the clients will use to access the server.
Example:

```OVPN_SERVER="my.server.net"```

### Create the container volume

Initialize the $OVPN_DATA container that will hold the configuration files and certificates.

```docker volume create --name $OVPN_DATA```

### Create openvpn initial configuration file:

```docker run -v $OVPN_DATA:/etc/openvpn --rm nvdias/rpi-openvpn ovpn_genconfig -u udp://$OVPN_SERVER```

### init pki 

Key generation in a Raspberry Pi 4 will take from 5 to 15 minutes !!!
You will be asked for:
- a passphrase (don't loose it - it will be needed for further configurations;
- a name for the CA KEY (just a easy name as: my.openvpn.server not used in normal operation);

WAIT ... 

After generation, the passphrase will be asked again.

```docker run -v $OVPN_DATA:/etc/openvpn --rm -it nvdias/rpi-openvpn ovpn_initpki```

### Edit config to make clients use local DNS
(e.g. so they can resolve local hostnames):

```docker run -v $OVPN_DATA:/etc/openvpn --rm -it nvdias/rpi-openvpn vi /etc/openvpn/openvpn.conf```

Add the following settings at the end of file (assuming Local network 192.168.0.0):
```push "dhcp-option DNS 192.168.0.1"```

### Start OpenVPN server process

```docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN nvdias/rpi-openvpn```

Or to install as a service:
```docker run -v $OVPN_DATE/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN --name openvpn --restart unless-stopped nvdias/rpi-openvpn```

### Create a client ###

```docker run -v $OVPN_DATA:/etc/openvpn --rm -it nvdias/rpi-openvpn easyrsa build-client-full USERNAME_GOES_HERE```

Retrieve the client configuration file (*.ovpn) with embedded certificates and give to the user:

```docker run -v $OVPN_DATA:/etc/openvpn --rm nvdias/rpi-openvpn ovpn_getclient USERNAME > USERNAME.ovpn```

## Inclusion in a kodi add-on ##

There are some issues, when running in a distribution as LibreELEC, because the network privileges are limited. Calling the "docker run" needs some adjusments.

[WORK IN PROGRESS]
