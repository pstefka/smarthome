#!/bin/bash

# login
curl -v -b cookie.txt -c cookie.txt -k -H "Content-Type: application/x-www-form-urlencoded" -d "login_authorization=$(cat 1)&current_page=Main_Login.asp&next_page=index.asp&group_id=&action_mode=&action_script=&action_wait=5&login_captcha=" -e "https://192.168.1.1:8443/Main_Login.asp" https://192.168.1.1:8443/login.cgi

# upload cert
curl -v -b cookie.txt -c cookie.txt -k -F "action_mode=" -F "action_script=" -F "action_wait=" -F "le_enable=2" -F "file_key=@privkey1.pem" -F "file_cert=@cert1.pem" -e https://192.168.1.1:8443/Advanced_ASUSDDNS_Content.asp https://192.168.1.1:8443/upload_cert_key.cgi

# apply
curl -v -b cookie.txt -c cookie.txt -k --data-raw 'productid=RT-AX58U&current_page=Advanced_ASUSDDNS_Content.asp&next_page=&modified=0&action_wait=10&action_mode=apply&action_script=prepare_cert%3Brestart_webdav&wl_gmode_protection_x=&le_enable=2' -e https://192.168.1.1:8443/Advanced_ASUSDDNS_Content.asp 'https://192.168.1.1:8443/start_apply.htm'
# curl -v -b cookie.txt -c cookie.txt -k --data-raw 'productid=RT-AX58U&current_page=Advanced_ASUSDDNS_Content.asp&next_page=&modified=0&action_wait=10&action_mode=apply&action_script=restart_ddns%3Bprepare_cert%3Brestart_webdav&preferred_lang=EN&firmver=3.0.0.4&ddns_enable_x=1&wl_gmode_protection_x=&ddns_wan_unit=-1&ddns_ipv6_update=1&ddns_server_x=CUSTOM&ddns_hostname_x=budabuda.duckdns.org&DDNSName=&ddns_regular_check=0&ddns_regular_period=60&ddns_refresh_x=1&le_enable=2' \ 'https://192.168.1.1:8443/start_apply.htm'
  
# logout
curl -v -b cookie.txt -c cookie.txt -k -e 'https://wifi.budabuda.duckdns.org:8443/index.asp' 'https://wifi.budabuda.duckdns.org:8443/Logout.asp'
