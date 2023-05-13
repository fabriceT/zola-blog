---
title: "SSL"
date: 2022-01-17
draft: true
---

# Authentification du client par certificats SSL pour un site web

1) Création d'une autorité racine de certifications avec mkcert

    mkcert -install

On peut obtenir les chemins de l'autoritité racine avec `mkcert -CAROOT`.

2) Création d'un certificat pour le service web

    mkcert 'guacamole.ad.pj-technologies.net'

Deux fichiers sont générés : `guacamole.ad.machin.net.pem` et `guacamole.ad.machin.net-key.pem`. Ils sont à copier sur le reverse-proxy.

On ne profitera pour copier également le certificat de l'autorité racine sur le serveur `rootCA.pem`

3) Configuration de nginx (reverse proxy)

    server {
        listen 443 ssl http2;
        server_name avocat.ad.machin.net;
        access_log /var/log/nginx/guacamole-ssl-access.log;
        error_log /var/log/nginx/guacamole-ssl-error.log;

        ssl_verify_client optional;

        location / {
            if ($ssl_client_verify != SUCCESS) {
                return 403;
            }

            proxy_pass http://10.20.230.53:8080/guacamole/;
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            access_log off;
        }

        ssl_protocols TLSv1.2;
        ssl_certificate /etc/ssl/guacamole.ad.machin.net.pem;
        ssl_certificate_key /etc/ssl/guacamole.ad.machin.net-key.pem;
        ssl_client_certificate /etc/nginx/ssl_clients/ca.crt;    # Certificat de l'autorité racine (rootCA.pem)
    }

4) Création d'un certificat client pour l'authentification

    mkcert -client lt-18hp07-pjt

Il faut convertir le certificat pour qu'il puisse être intégré à Windows

    openssl pkcs12 -inkey lt-18hp07-pjt-key.pem -in lt-18hp07-pjt.pem -export -out lt-18hp07-pjt.pfx

