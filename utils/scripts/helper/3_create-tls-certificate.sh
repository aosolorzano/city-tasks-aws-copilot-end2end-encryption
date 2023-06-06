#!/usr/bin/env bash

cd "$WORKING_DIR"/utils/docker/envoy/certs || {
  echo "Error moving to the Docker Envoy-Certs directory."
  exit 1
}

# Generate CA self-signed certificate.
read -r -p 'Please, enter the <Root Domain Name> for the CA certificate: [example.com] ' root_domain_name
if [ -z "$root_domain_name" ]; then
  root_domain_name='example.com'
fi
echo ""
rm -f ./*.pem
openssl req -x509 -nodes    \
  -newkey rsa:4096          \
  -days   365               \
  -keyout ca-key.pem        \
  -out    ca-crt.pem        \
  -subj "/C=EC/ST=Pichincha/L=UIO/O=Hiperium Co./OU=Innovation/CN=*.$root_domain_name/emailAddress=contact@$root_domain_name" || {
  echo "Error generating domain name TLS certificate."
  exit 1
}
echo "DONE!"

# Generate CSR certificate for Web Server.
echo ""
read -r -p 'Please, enter the <Server Domain Name> for the CSR certificate: [example.io] ' server_domain_name
if [ -z "$server_domain_name" ]; then
  server_domain_name='example.io'
fi
echo ""
openssl req -nodes          \
  -newkey rsa:4096          \
  -days   365               \
  -keyout server-key.pem    \
  -out    server-req.pem    \
  -subj "/C=EC/ST=Pichincha/L=UIO/O=Hiperium Cloud/OU=Smart Cities/CN=*.$server_domain_name/emailAddress=contact@$server_domain_name" || {
  echo "Error generating CSR web server certificate."
  exit 1
}
echo "DONE!"

echo ""
echo "Using CA private key to sign the Web Server certificate..."
echo ""
echo "subjectAltName = DNS:*.$server_domain_name" > v3.ext
openssl x509                \
  -req                      \
  -in     server-req.pem    \
  -CA     ca-crt.pem        \
  -CAkey  ca-key.pem        \
  -CAcreateserial           \
  -out    server-crt.pem    \
  -extfile v3.ext        || {
  echo "Error signing Web Server TLS certificate."
  exit 1
}
echo "DONE!"
