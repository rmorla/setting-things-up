#!/bin/bash
# https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

export HOME=~/ca-ssr
rm -rf $HOME/ca
mkdir $HOME/ca
cd $HOME/ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

cp $HOME/openssl-2-root.conf $HOME/ca/openssl.conf

# root CA key and certificate
echo ">>>>> root CA key and certificate"
openssl genrsa -aes256 -passout pass:1234 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.conf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem -subj "/CN=www.modelCA.com/O=Model CA LTD./ST=VA/C=US"
chmod 444 certs/ca.cert.pem

# intermediate CA
echo ">>>>> intermediate CA"

mkdir $HOME/ca/intermediate
cd $HOME/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > $HOME/ca/intermediate/crlnumber

cp $HOME/openssl-2-intermediate.conf $HOME/ca/intermediate/openssl.conf

# intermediate CA key and csr
echo ">>>>> intermediate CA key and csr"

cd $HOME/ca/intermediate

openssl genrsa -aes256 -passout pass:1234 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

openssl req -config openssl.conf -new -sha256 -key private/intermediate.key.pem -out csr/intermediate.csr.pem -subj "/CN=interm.modelCA.com/O=Model CA LTD./ST=VA/C=US"

# intermediate CA certificate 
echo ">>>>> intermediate CA certificate"
cd $HOME/ca
openssl ca -config openssl.conf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem

# intermediate certificate chain
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem


