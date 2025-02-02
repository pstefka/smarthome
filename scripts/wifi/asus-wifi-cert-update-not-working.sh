#!/usr/bin/env bash

/etc/key.pem
/etc/cert.pem
/etc/cakey.pem
/etc/cacert.pem

https://gist.github.com/adorobis/d05483a012b0f44286df886f773b5fe9
https://gist.github.com/davidbalbert/6815258


ls /etc/*.pem
rm /etc/*.pem
rm /tmp/etc/*.pem
rm /jffs/.cert/*.pem
#rm /jffs/cert.tgz
nvram set https_crt_save=0
nvram unset https_crt_file
service restart_httpd
nvram unset https_crt_file
service restart_httpd
nvram get https_crt_file
sleep 20
ls /etc/*.pem
rm /etc/*.pem
rm /tmp/etc/*.pem
rm /jffs/.cert/*.pem
#rm /jffs/cert.pem
#nvram set https_crt_save=1

cat <<EOT > /etc/cert.pem
-----BEGIN CERTIFICATE-----
MIID6zCCAlOgAwIBAgIQf+60bvX6+28Ta9ap5y3UuzANBgkqhkiG9w0BAQsFADBL
MR4wHAYDVQQKExVta2NlcnQgZGV2ZWxvcG1lbnQgQ0ExEDAOBgNVBAsMB251Y0Bu
dWMxFzAVBgNVBAMMDm1rY2VydCBudWNAbnVjMB4XDTI1MDExNzIzNDc1NVoXDTI3
MDQxNzIyNDc1NVowOzEnMCUGA1UEChMebWtjZXJ0IGRldmVsb3BtZW50IGNlcnRp
ZmljYXRlMRAwDgYDVQQLDAdudWNAbnVjMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAw+NmOOzYPRu/B2anjR8IS/VOWSFVV78tnykubmTJxolkh52Hiew2
lfx3MD3H4ymDrN6lsDmUIox131VDQ3mpD24WKmLM0BcPARknxTD4wBmOpEzbNs2R
H473Lq/nr5sapxCWvJ4VNIN9ttamSjMzvki72tbZHtwjdmv6P1XJzdXVDlN+Nri8
i7JuPRBBItJhKUbXAn4aVYJ35/SxbpSrTfsQeX+jxzyq9qD9xK6tD/CiLZeW+2z0
FSO58tJqoAplbwzVo8V+UgaY53hIlbTWSdGyiqa3KOtU2nOhevkt+l2/8OMKHuBu
7YMm7tVMa4HOW+z6yLbbn8OvlL49cnE11wIDAQABo1swWTAOBgNVHQ8BAf8EBAMC
BaAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwHwYDVR0jBBgwFoAUTNqTo3s8xyHTvtXL
JJeMD2xrPaUwEQYDVR0RBAowCIIGYmxhYmxhMA0GCSqGSIb3DQEBCwUAA4IBgQA+
LwsO1Y5vAxP8cXIIquNjM4CZ1sc4dD/MTE17u/Dq3lk8uincZvkaoQD4LnHB6/hi
HEugHGyNSVRbS2Rlaxv8b2TAFIPhpmdYjOg6Oh4CkNGvKE+09WvMquoHvAbfHPm1
beuIm4o5cFXz1ypb/eAMX4fBfhS+jpfFRhk+46e+1+mxPmfAEj7W23Tclmuj6MVE
yJu7YUIWXG7xCkrtzyHFHPnvqq5Bt2tgGEFmDk/JR7FY9FaVMahaOKxUfeIcu/zl
AeqmDM1BJ5cUYuGlSz8W31q2yR25S4iVvcgCmOw/8exVLuPaI69i1M+zUF87BXT6
2ZZsduESJI7jj0j3U3RG1fLVlBxh2yOnZC7milYN62jEmbmepcDPbm1sdJZtQOVW
6ICXozFZaOcr85yCSHZRf2nuXcR3ir8LOVHgQ0CYA8JVckvL8yDdFNBaA3RmoJ3X
uAlQ+AlfMy10Jk1tcjfJ14T7JXBIBJYsogn2Qp7sUn1mbTEhP4Z6+5OaJ5bzsEI=
-----END CERTIFICATE-----
EOT

cat <<EOT > /etc/key.pem
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDD42Y47Ng9G78H
ZqeNHwhL9U5ZIVVXvy2fKS5uZMnGiWSHnYeJ7DaV/HcwPcfjKYOs3qWwOZQijHXf
VUNDeakPbhYqYszQFw8BGSfFMPjAGY6kTNs2zZEfjvcur+evmxqnEJa8nhU0g322
1qZKMzO+SLva1tke3CN2a/o/VcnN1dUOU342uLyLsm49EEEi0mEpRtcCfhpVgnfn
9LFulKtN+xB5f6PHPKr2oP3Erq0P8KItl5b7bPQVI7ny0mqgCmVvDNWjxX5SBpjn
eEiVtNZJ0bKKprco61Tac6F6+S36Xb/w4woe4G7tgybu1Uxrgc5b7PrIttufw6+U
vj1ycTXXAgMBAAECggEALNKXzWbEhBcZOwROSohTSa4z40kxUga41baCnVgKo5dE
nZN6NCEMzH0ceLlqR5x0ONYpa42BS/Z/8j58SbBI8vLpt4EsBGGCWWn8I670/F/c
t9OuRXf8QRBhlxlBFnmTO68cDsTNbVq5JWEwY8IbkOrrsUOAIwOUScCjXmKu7p4c
WF6lgDm3ZsyXoHZFvoREasJJnZe2zPRpLOJWgQ7yVimiqjLyMjKXnlNr/HHBbWas
vtNAt9hoWB8WOnmrDXKBd4FaOgxiPAlnDTLbyGzgsh131pCKejEyYv+vZFJ7YF+s
DBnsagm/9Wf6d8dDSkrq5knzgeBCEkX3D3nud4vC4QKBgQD12ZAR+tzmS8aLIoHW
FVVeZrdTpTko1N9AWAu6lxG901wypQas6s4AeEdkvJ8VPP7r6HEldAMI2LtX5p66
Zw0hEB0bEj5F+agOqbfBcHVmbvm0m8kl5hurbOi/f82qzKPyAtoiKBafjbV1RLm1
qo7w8iDNS2KJdQHsAr8G0WzejQKBgQDL+chOr4vzMZTrR6kC+RrnU3u0QiM0NJTo
vUJtiADJeVLZ8MiCanONLwT0Drkcyf9DmB3HclzfjNtnJHHeq+Lb/0obv4H1E9FG
L2Evet2iRCubiLRxME/BHpHgEawHmj8oV8ZAU0cCq6tH07tkMkOOqQPMmKW3qdWc
sQyzXDdO8wKBgQCpRjeQaa4XUy1NN2E2SlIRQaAQk76bgpaE8xqASuwIS7M7m6zQ
+osEf8yIa+cM9IaBX/Yn140PVksH5t57ceD0Vufzb8g43gD8t5ayNgBfmyGLXYhN
8/YxPjezQwgVBfoL9DLFOdz51tSN/dfwYZMyC0TSlYkvI8VC/1EQHLpdMQKBgFJz
Lie4R+7O3O5Z8hR0kw5srXVIwqgolQSa9A4ISqEl/HqCHNqyovCvz+XDSco8UIWH
KIplTOtEKa/AiJLEkhfxUohy2dox34bqQfOKS6p6udHN6XpTV/mtHLQhEJOmIt9w
039O6kZHFB4dlQLEWpCA+zspfNsHuIP1AThDD0xHAoGBAKwhcSZ/oI1as4hvhTPZ
w+QzrY52X8k/fPldgeKhvztKuY2iXmo6h/hT858I9EpG+QIqOan5xD0e2jw7eVT/
kevzz9TVDp3K2/0XdYzgFri+JjsliO/LjQLdxpeucGy5s8Hbh6kDsC4Cbtu/d96U
UoMXP2y0imp7ozyJRq9fq1eY
-----END PRIVATE KEY-----
EOT

cat /etc/key.pem > /etc/server.pem
cat /etc/key.pem > /etc/server.pem
cp /etc/key.pem /jffs/.cert/key.pem
cp /etc/cert.pem /jffs/.cert/cert.pem
cp /etc/key.pem /tmp/etc/key.pem
cp /etc/cert.pem /tmp/etc/cert.pem

#rm /jffs/cert.tgz
#tar -C / -czf /jffs/cert.tgz etc/cert.pem etc/key.pem

mkdir /tmp/certtgz
cd /tmp/certtgz
mv /jffs/cert.tgz .
tar -xzf cert.tgz
rm cert.tgz
cp /etc/cert.pem ./etc
cp /etc/key.pem ./etc
tar -czf cert.tgz *
mv cert.tgz /jffs/cert.tgz

nvram set https_crt_save=1
#nvram set https_crt_file="$(/usr/sbin/openssl enc -base64 < /jffs/cert.tgz | tr -d '\n')"
nvram set https_crt_file=/jffs/cert.tgz
service restart_httpd
nvram get https_crt_file

cd /etc
#rm -rf /tmp/certtgz
