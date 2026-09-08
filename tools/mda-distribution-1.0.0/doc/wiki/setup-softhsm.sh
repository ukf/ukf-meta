#!/usr/bin/sh

# Clear any previous softhsm setup
rm -rf softhsm
mkdir -p softhsm/tokens

# Create configuration file
export SOFTHSM2_CONF=$PWD/softhsm/softhsm2.conf
echo "directories.tokendir = $PWD/softhsm/tokens" >$SOFTHSM2_CONF

# Initialise the token
softhsm2-util --init-token --slot 0 --label "test" \
    --so-pin 1234 \
    --pin 12341234

# Load the credential
keytool -importkeystore --addprovider SunPKCS11 -providerarg path/to/input/pkcs11-softhsm.cfg \
    -srcstoretype pkcs12 -srckeystore path/to/secrets/self-signed.p12 -srcstorepass password \
    -deststoretype PKCS11 -destkeystore NONE -deststorepass 12341234

keytool -list --addprovider SunPKCS11 -providerarg path/to/input/pkcs11-softhsm.cfg \
    -storetype PKCS11 -keystore NONE -storepass 12341234
