export HOME=~/ca-ssr

# server certificate 
echo ">>>>> create wwwserver csr"

rm -rf $HOME/wwwserver
mkdir $HOME/wwwserver
cd $HOME/wwwserver
mkdir certs crl newcerts private csr

openssl genrsa -aes256 -passout pass:1234 -out private/wwwserver.key.pem 4096
chmod 400 private/wwwserver.key.pem

openssl req -key private/wwwserver.key.pem -new -sha256 -out csr/wwwserver.csr.pem -subj "/CN=www.server.com/O=WWW LTD./ST=VA/C=US"

# sign certificate 
echo ">>>>> sign wwwserver certificate"

cd $HOME/ca/intermediate

openssl ca -config openssl.conf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in $HOME/wwwserver/csr/wwwserver.csr.pem \
      -out certs/wwwserver.cert.pem
chmod 444 certs/wwwserver.cert.pem

cp certs/wwwserver.cert.pem $HOME/wwwserver/certs/wwwserver.cert.pem

echo ">>>>> verify wwwserver certificate"
cd $HOME/wwwserver
openssl x509 -noout -text \
      -in certs/wwwserver.cert.pem