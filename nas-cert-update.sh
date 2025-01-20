#!/usr/bin/env bash

wget https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.1.0.tar.gz
tar -xzf 3.1.0.tar.gz
/usr/syno/etc/certificate/system/FQDN/cert.pemcd acme.sh-3.1.0

./acme.sh -m www.stefi@gmail.com --issue -d pornonas.budabuda.duckdns.org --dns dns_duckdns --cert-file /tmp/cert.pem --key-file /tmp/privkey.pem --fullchain-file /tmp/fullchain.pem --server letsencrypttest --keylength 2048

https://github.com/catchdave/ssl-certs/blob/main/replace_synology_ssl_certs.sh

remove /usr/syno/bin/synow3tool --gen-all
replace /usr/syno/bin/synoctl restart -> /usr/syno/sbin/synoservice --restart

#https://community.synology.com/enu/forum/1/post/149358
#https://global.download.synology.com/download/Document/Software/DeveloperGuide/Firmware/DSM/All/enu/Synology_DiskStation_Administration_CLI_Guide.pdf 
synoservice --list
synoservice --restart nginx
synoservice --restart ftpd
synoservice --restart ftpd-ssl
