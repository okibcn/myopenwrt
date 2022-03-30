#!/bin/sh

cd /etc/ssl/
# Create CA key and certificate. Import ca.crt as root certificate to the computers accessing the router and save ca.key for future use.
[ -e "./ca.key" ] || openssl genrsa -out ca.key 2048
[ -e "./ca.crt" ] || openssl req -new -x509 -days 7300 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA" -out ca.crt

# Create server key and certificate. use server.key and server.crt as valid files for uhttpd, ttyd, etc.
[ -e "./server.key" ] || openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=localhost" -out server.csr
echo "subjectAltName=IP:192.168.1.1,IP:10.1.1.1,DNS:e8450.lan,DNS:mioki.hopto.org" > subjectAltName.txt
openssl x509 -sha256 -req -extfile subjectAltName.txt -days 825 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
