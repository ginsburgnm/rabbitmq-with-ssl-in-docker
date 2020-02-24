#!/bin/bash

set -eu

#
# Prepare the certificate authority (self-signed).
#
cd /home/testca

# Create a self-signed certificate that will serve a certificate authority (CA).
# The private key is located under "private".
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 \
    -out ca_certificate.pem -outform PEM -subj /CN=MyTestCA/ -nodes

# Encode our certificate with DER.
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

#
# Prepare the server's stuff.
#
cd /home/server

# Generate a private RSA key.
openssl genrsa -out private_key.pem 2048

# Generate a certificate from our private key.
openssl req -new -key private_key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=server/ -nodes

# Sign the certificate with our CA.
cd /home/testca
openssl ca -config openssl.cnf -in /home/server/req.pem -out \
    /home/server/server_certificate.pem -notext -batch -extensions server_ca_extensions

# Create a key store that will contain our certificate.
cd /home/server
openssl pkcs12 -export -out server_certificate.p12 -in server_certificate.pem -inkey private_key.pem \
    -passout pass:roboconf
