#/bin/bash

# Create keystone configuration file
cat << EOF >> cert.cnf
[ req ]
prompt                  = no
distinguished_name      = keyrock
req_extensions          = v3_req
 
[ keyrock ]
commonName              = keyrock
stateOrProvinceName     = FiWare
countryName             = ES
emailAddress            = ks@fiware.eu
organizationName        = Fiware
organizationalUnitName  = keyrock
 
[ v3_req ]
basicConstraints        = CA:FALSE
keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName          = @alt_names
 
[ alt_names ]
IP          = 127.0.0.1
DNS.1	    = localhost
EOF

# Generate CSR
openssl req -config cert.cnf -nodes -x509 -newkey rsa:4096 -keyout server.key -out server.pem

# Copy certificates
cp server.key /horizon/certs/horizon.key
cp server.key /keystone/certs/keystone.key
cp server.pem /horizon/certs/horizon.pem
cp server.pem /keystone/certs/keystone.pem

