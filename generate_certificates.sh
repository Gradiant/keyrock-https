#/bin/bash
# Copyright (C) 2017  Gradiant <https://www.gradiant.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

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

