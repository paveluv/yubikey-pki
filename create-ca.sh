#!/bin/bash

# Generate a new x509 Certificate Authority on yubikey smartcard and store it in PIV slot 9c.
# The private key is generated on yubikey and never leaves the device.

. common.sh

: ${O:=puvar.net}
: ${OU:=CA}
CN=${1:-puvar.net}
CA=${2:-puvarCA}
PIN=$(piv_pin)
MGM_KEY=$(piv_mgm_key)

# Gpg-agent may hold a lock on the card, so kill it before proceeding.
pkill gpg-agent
sleep 1

# Generate a new private key. It will never leave the device.
yubico-piv-tool -s9c -agenerate -k$MGM_KEY >${CA}_pub_key.txt
# Generate and import a temporary certificate (needed to make the private key visible).
yubico-piv-tool -s9c -S'/CN=bar/OU=test/O=example.com/' -averify -aselfsign -P$PIN <${CA}_pub_key.txt >temp_${CA}_cert.txt
yubico-piv-tool -s9c -aimport-certificate -k$MGM_KEY <temp_${CA}_cert.txt
rm -f temp_${CA}_cert.txt

gen_config >${CA}.cnf

touch certindex

# Generate a new certificate and sign it with the key from slot 9c ("-key 02" means id 02).
openssl req -new -x509 -nodes -config ${CA}.cnf -engine pkcs11 -keyform engine -key 02 -passin pass:$PIN -sha256 -days 36500 -out ${CA}.crt

# Put the new certificate to slot 9c (replace the temporary one).
yubico-piv-tool -s9c -aimport-certificate -k$MGM_KEY <${CA}.crt

# Generate an empty crl.
test -f crlnumber || echo "00" >crlnumber
openssl ca -config ${CA}.cnf -engine pkcs11 -keyform engine -keyfile 02 -passin pass:$PIN -gencrl -crldays 3650 -out ${CA}.crl
# ca_with_crl is needed for dovecot.
cat ${CA}.crt ${CA}.crl >${CA}_with_crl.pem
