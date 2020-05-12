# OpenVPN server in docker complete with an EasyRSA PKI CA.

Container was initially tagged from mjenz/rpi-openvpn, which in turn is kylemanna/docker-openvpn with an armhf base image.

This source was forked in order to be used in a kodi add-on to allow easy vpn implementation in closed systems like LibreELEC.

Easyrsa was also updated to support additional command line parameters to enable full silent processing [WIP]


The docker container: rpi-openvpn

This git repository: nvdias0/rpi-dockeropenvpn

The git repository for the kodi add-on: nvdias0/docker.openvpn.server


## INSTALL

Assuming docker is already installed (sudo apt-get install docker), executing one of the QUICK START docker commands will automatically download the <latest> image from the docker hub


### BUILD

If you want to change and build this git yourself:

a) Clone this respository in your local storage:

``` git clone https://github.com/nvdias0/rpi-docker-openvpn.git ```

b) Build a local docker image and name-it "nvdias/rpi-openvpn":

``` docker build -t nvdias/rpi-openvpn rpi-docker-openvpn/ ```



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

### Init pki 

Key generation in a Raspberry Pi 4 will take from 5 to 15 minutes !!!
You will be asked for:
- a passphrase (don't loose it - it will be needed for further configurations;
- a name for the CA KEY (just a easy name as "my openvpn server" - not used in normal operation);

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


## Install the kodi add-on:

A kodi add-on is now working with LibreELEC on Raspberry Pi.

It downloads the docker image automatically.

You just need to configure server and clients - there are 2 scripts to help that process.


Just follow the instructions in the kodi add-on git :

nvdias0/docker.openvpn.server



## WIP - silent easyrsa
(Passing options thought the command line.)

By default easyrsa has an interactive approach to securely receive passwords from the keyboard.

The version bundled in this repository, has a slightly changed eayrsa that can include the contents of 2 environment variables when internally calling openssl:

$EASYRSA_GENREQ_OPTS  as additional key generation options:

   Examples:

     EASYRSA_GENREQ_OPTS="-passout pass:my-secret"

     EASYRSA_GENREQ_OPTS="-passout file:file_with_my-secret"
  
$EASYRSA_SIGNREQ_OPTS as additional signing options

   Examples:  

     EASYRSA_SIGNREQ_OPTS="-passin pass:ca-secret_for_validation"
 
     EASYRSA_SIGNREQ_OPTS="-passin file:file_with_ca-secret_for_validation"


### EXAMPLE: init_pki (password in command line):

	docker run --rm -it \
           -v $OVPN_DATA:/etc/openvpn \ 
           -e "EASYRSA_GENREQ_OPTS=-passout pass:CA_SECRET" \
           -e "EASYRSA_SIGNREQ_OPTS=-passin pass:CA_SECRET" \
           nvdias/rpi-openvpn \
           bash -c "echo OpenVPN Server name | ovpn_initpki"

	 
### EXAMPLE: Create a client (password in command line):
 
	docker run --rm -it \
          -v $OVPN_DATA:/etc/openvpn \
		  -e "EASYRSA_GENREQ_OPTS=-passout pass:USER-PASSWORD" \
		  -e "EASYRSA_SIGNREQ_OPTS=-passin pass:CA_SECRET" \
		  nvdias/rpi-openvpn \
		  easyrsa build-client-full USERNAME
 
