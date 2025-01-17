#!/usr/bin/env bash


/usr/syno/etc/certificate/system/default/cert.pem
/usr/syno/etc/certificate/system/default/fullchain.pem
/usr/syno/etc/certificate/system/default/privkey.pem

/usr/syno/etc/certificate/system/FQDN/cert.pem
/usr/syno/etc/certificate/system/FQDN/privkey.pem
/usr/syno/etc/certificate/system/FQDN/fullchain.pem

/usr/syno/etc/certificate/smbftpd/ftpd/cert.pem
/usr/syno/etc/certificate/smbftpd/ftpd/privkey.pem
/usr/syno/etc/certificate/smbftpd/ftpd/fullchain.pem


#https://community.synology.com/enu/forum/1/post/149358
#https://global.download.synology.com/download/Document/Software/DeveloperGuide/Firmware/DSM/All/enu/Synology_DiskStation_Administration_CLI_Guide.pdf 
synoservice --list
synoservice --restart nginx
synoservice --restart ftpd
synoservice --restart ftpd-ssl
