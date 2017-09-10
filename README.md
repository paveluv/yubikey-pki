# yubikey-pki

A simple set of scripts for managing PKI with the CA stored on Yubikey.
It can potentially be modified to work with any smartcard that supports PIV.

The private key for the CA is generated on Yubikey and never leaves the device.



## Tested with
### macOS
Install the following packages from brew:
* openssl: stable 1.0.2l
* engine_pkcs11: stable 0.1.8
* opensc: stable 0.17.0

### Linux
Not tested yet.