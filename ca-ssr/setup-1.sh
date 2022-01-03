#!/bin/bash
export MYHOME=~/ca-ssr
rm -rf $MYHOME/ca
mkdir $MYHOME/ca
cd $MYHOME/ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
cp $MYHOME/openssl-1.conf $MYHOME/ca/openssl.conf
export REG="s|THISISHOME|${MYHOME}|"
sed -i $REG $MYHOME/ca/openssl.conf
# 1. ca

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -keyout ca.key -out ca.crt -subj "/CN=www.modelCA.com/O=Model CA LTD./C=US" -passout pass:1234 
openssl x509 -in ca.crt -text -noout

# 2. server csr
rm -rf $MYHOME/wwwserver
mkdir $MYHOME/wwwserver
cd $MYHOME/wwwserver

openssl req -newkey rsa:2048 -sha256 -keyout server.key -out server.csr -subj "/CN=www.bank32.com/O=Bank32 Inc./C=US" -passout pass:4321
openssl req -in server.csr -text -noout

# 3. 
cd $MYHOME/ca
openssl ca -config openssl.conf -policy policy_anything -md sha256 -days 3650 -in ../wwwserver/server.csr -out server.crt -batch -cert ca.crt -keyfile ca.key