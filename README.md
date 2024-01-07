## Credits
https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309
https://hub.docker.com/_/httpd

## Steps to deal with SSL certs.

1. Create a root CA key:

openssl genrsa -des3 -out containerCA.key 4096 

2. Create a root CA certificate:

openssl req -x509 -new -nodes -key containerCA.key -sha256 -days 1024 -out containerCA.crt

3. Create a container key:

openssl genrsa -out container.key 2048

4. Create a container CSR that specifies SANs (because Chrome is a pain).

openssl req -new -sha256 \
    -key container.key \
    -subj "/C=US/ST=Kentucky/O=Container/OU=Container/CN=docker.container" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:docker.container")) \
    -out container.csr

5. Create a container certificate using that CSR and specifying SANs:

openssl x509 -req -extfile <(printf "subjectAltName=DNS:docker.container") -days 1200 -in container.csr -CA containerCA.crt -CAkey containerCA.key -CAcreateserial -out container.crt -sha256

6. Import the container root cert in to your trusted root certification authorities.

7. Import the container certificate in to your Personal Certificates.

8. Profit.

## Steps to deal with HTTPD setup

1. Copy the static HTML files in to /usr/local/apache2/htdocs/

2. Copy the container cert and key in to /usr/local/apache2/conf/

3. In httpd.conf, uncomment the following lines:

    - #LoadModule socache_shmcb_module modules/mod_socache_shmcb.so

    - #LoadModule ssl_module modules/mod_ssl.so

    - #Include conf/extra/httpd-ssl.conf

4. In httpd-ssl.conf, make sure that SSLCertificateFile and SSLCertificateKeyFile point to the right location.

5. Copy httpd.conf to /usr/local/apache2/conf/

6. Copy http-ssl.conf to /usr/local/apache2/conf/extra/

## DNS updates

Update your HOSTS file to deal with docker.container being pointed at 127.0.0.1.

## Build and Run