#!/usr/bin/env bash

# install acme.sh
wget https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.1.0.tar.gz
tar -xzf 3.1.0.tar.gz
cd acme.sh-3.1.0/

# use acme.sh
./acme.sh -m www.stefi@gmail.com --issue -d nas.budabuda.duckdns.org --dns dns_duckdns --cert-file /tmp/cert.pem --key-file /tmp/privkey.pem --fullchain-file /tmp/fullchain.pem --server letsencrypttest --keylength 2048

# use generated certificates in DSM
./replace_synology_ssl_certs.sh