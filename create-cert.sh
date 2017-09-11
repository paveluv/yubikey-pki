#!/bin/bash

# Generate a certificate and sign it with CA from yubikey.
# Pack the key and the certificate into p12 for exporting.

. common.sh

: ${O:=puvar.net}
OU=$1
CN=${2:-puvar}
CA=${3:-puvarCA}

test -z "${OU}" && { 
    echo "provide OU"
    exit 1
}

PIN=$(piv_pin)

# Gpg-agent may hold a lock on the card, so kill it before proceeding.
pkill gpg-agent
sleep 1

#openssl ecparam -name secp256k1 -genkey -noout -out ${OU}.key
openssl genrsa -out ${OU}.key 2048
gen_config >${OU}.cnf
openssl req -new -config ${OU}.cnf -key ${OU}.key -out ${OU}.csr

OPENSSL_CONF=${OU}.cnf openssl x509 -engine pkcs11 -CAkeyform engine -CAkey 02 -passin pass:$PIN -sha256 -CA ${CA}.crt -CAcreateserial -req -in ${OU}.csr -extfile ${OU}.cnf -out ${OU}.crt -days 365 -extensions v3_req

openssl pkcs12 -export -clcerts -inkey ${OU}.key -in ${OU}.crt -out ${OU}.p12 -name ${OU}
