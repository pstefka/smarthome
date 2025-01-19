#!/usr/bin/env bash

set -euo pipefail

check_variable_set() {
  if [ -z ${!1+x} ]; then
    error "Please specify ENV variable \"${1}\""
    exit 1
  fi
}

check_file() {
  if [ ! -f ${1} ]; then
    error "File \"${1}\" doesn't exist"
    exit 1
  fi
}

info() {
  echo -e "\e[94m${1}\e[0m"
}

error() {
  echo -e "\e[31m${1}\e[0m"
}

WIFI_URL=${WIFI_URL:-https://192.168.1.1:8443}
INSECURE=${INSECURE:-true}
PRIVATE_KEY=${PRIVATE_KEY:-privkey.pem}
CERTIFICATE=${CERTIFICATE:-cert.pem}

echo "Using URL \"${WIFI_URL}\""

if [[ ${INSECURE} == "true" ]]; then
  FLAGS=" -k"
  echo "Using insecure flag"
fi

check_variable_set USERNAME
echo "Using \"${USERNAME}\" as username"
check_variable_set PASSWORD
echo "Using \"$(echo -n "${PASSWORD}" | sed -e 's/./*/g')\" password (hidden)"

echo "Using ${PRIVATE_KEY} as private key file"
check_file ${PRIVATE_KEY}
echo "Using ${CERTIFICATE} as public certificate file"
check_file ${CERTIFICATE}

authorization=$(echo -n "${USERNAME}:${PASSWORD}" | base64 -w 0)

info "Logging in"
# login
curl -v -b cookie.txt -c cookie.txt -k -H "Content-Type: application/x-www-form-urlencoded" -d "login_authorization=${authorization}&current_page=Main_Login.asp&next_page=index.asp&group_id=&action_mode=&action_script=&action_wait=5&login_captcha=" -e "https://192.168.1.1:8443/Main_Login.asp" https://192.168.1.1:8443/login.cgi

info "Uploading certificate"
# upload cert
curl -v -b cookie.txt -c cookie.txt -k -F "action_mode=" -F "action_script=" -F "action_wait=" -F "le_enable=2" -F "file_key=@privkey1.pem" -F "file_cert=@cert1.pem" -e https://192.168.1.1:8443/Advanced_ASUSDDNS_Content.asp https://192.168.1.1:8443/upload_cert_key.cgi

info "Applying certificate"
# apply
curl -v -b cookie.txt -c cookie.txt -k --data-raw 'productid=RT-AX58U&current_page=Advanced_ASUSDDNS_Content.asp&next_page=&modified=0&action_wait=10&action_mode=apply&action_script=prepare_cert%3Brestart_webdav&wl_gmode_protection_x=&le_enable=2' -e https://192.168.1.1:8443/Advanced_ASUSDDNS_Content.asp 'https://192.168.1.1:8443/start_apply.htm'
# curl -v -b cookie.txt -c cookie.txt -k --data-raw 'productid=RT-AX58U&current_page=Advanced_ASUSDDNS_Content.asp&next_page=&modified=0&action_wait=10&action_mode=apply&action_script=restart_ddns%3Bprepare_cert%3Brestart_webdav&preferred_lang=EN&firmver=3.0.0.4&ddns_enable_x=1&wl_gmode_protection_x=&ddns_wan_unit=-1&ddns_ipv6_update=1&ddns_server_x=CUSTOM&ddns_hostname_x=budabuda.duckdns.org&DDNSName=&ddns_regular_check=0&ddns_regular_period=60&ddns_refresh_x=1&le_enable=2' \ 'https://192.168.1.1:8443/start_apply.htm'
  
info "Logging out"
# logout
curl -v -b cookie.txt -c cookie.txt -k -e 'https://wifi.budabuda.duckdns.org:8443/index.asp' 'https://wifi.budabuda.duckdns.org:8443/Logout.asp'
