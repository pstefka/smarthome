wget https://github.com/acmesh-official/acme.sh/archive/refs/tags/3.1.0.tar.gz
tar -xzf 3.1.0.tar.gz
cd acme.sh-3.1.0

#./acme.sh -m www.stefi@gmail.com --issue -d wifi.budabuda.duckdns.org --dns dns_duckdns --cert-file /jffs/.cert/cert.pem --key-file /jffs/.cert/key.pem --fullchain-file /tmp/chain.pem --reloadcmd "service restart_httpd" --server letsencrypt --force
./acme.sh -m www.stefi@gmail.com --issue -d wifi.budabuda.duckdns.org --dns dns_duckdns --cert-file /jffs/.cert/cert.pem --key-file /jffs/.cert/key.pem --reloadcmd "service restart_httpd" --server letsencrypt --force
