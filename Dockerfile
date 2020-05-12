# Original credit: https://github.com/jpetazzo/dockvpn
#
# Updated by nvdias 2020
# Easy RSA update to accept extra gen and sgn options - see docs


# Smallest base image - recent versions are not yet compatible with ovpn scripts.
FROM alpine:3.7

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Update easy-rsa
ADD ./easy-rsa /usr/share/easy-rsa
RUN chmod a+x  /usr/share/easy-rsa/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
