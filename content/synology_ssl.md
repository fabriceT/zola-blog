---
title: "NAS synology en reverse proxy : SSL"
date: 2020-11-11
#update: 2020-06-14

taxonomies:
  tags:
    - note
    - ssl
    - nginx
    - synology
  categories:
    - système
---

J'ai précédemment abordé la configuration d'un [NAS synology comme reverse proxy](/synology-rproxy/), sans passer par la case portail d'application.

Nous allons voir ici comment configurer le reverse proxy. Cela va s'articuler en 3 étapes :

* Configurer le service en HTTP ;
* Faire la demande de certificat SSL chez Let's Encrypt ;
* Finaliser la configuration du reverse proxy.

Pour la première étape. Nous allons créer un squelette de configuration permettant le [challenge](https://tools.ietf.org/html/rfc8555) avec Let's Encrypt.

    server {
        listen 80;
        listen [::]:80;

        server_name gitea.kill-swit.ch;

        allow all;
        location ^~ /.well-known/acme-challenge {
        root /var/lib/letsencrypt;
        default_type text/plain;
    }
    }


N'oubliez pas qu'il faut que l'on puisse résoudre le nom DNS et que le port 80 soit ouvert sur le NAS.

Deuxième étape, on remplit normalement la demande de certificat Let's Encrypt dans le panneau de configuration du NAS (Security -> Certificate). Le challenge va réussir, m'enfin !

La partie chafouine est de récupérer le certificat correspondant. Les certificats ainsi récupérés sont stockés dans le répertoire `/usr/syno/etc/certificate/_archive/`, suivi d'un nom de répertoire de 6 caractères qui semble est le résultat d'un hash. L'horodatage vous aiguillera sur le bon répertoire. 

Note : J'espère le système utilise le nom du serveur pour générer le hash.

Il est temps de passer à la troisième étape, c'est-à-dire créer la configuration pour SSL et rediriger le trafic dessus. Le squelette sera de la forme :

    server {
        listen 80;
        listen [::]:80;

        server_name gitea.kill-swit.ch;

        allow all;
        
        location ^~ /.well-known/acme-challenge {
            root /var/lib/letsencrypt;
            default_type text/plain;
        }
            
        location / {
            return 301 https://$server_name/$request_uri;
        }
    }
    
    server {
        listen 443;
        listen [::]:443;

        server_name gitea.kill-swit.ch;

        allow all;

        # On place le chemin où le syno à placer le certificat lors du challenge.
        ssl_certificate     /usr/syno/etc/certificate/_archive/DA6dCJ/fullchain.pem;
        ssl_certificate_key /usr/syno/etc/certificate/_archive/DA6dCJ/privkey.pem;

        location / {
            proxy_http_version 1.1;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Proto $scheme;

        proxy_pass http://127.0.0.1:8040;
        }
    }


Voilà.

Peut-être y aura-t-il une partie 3 quand le certificat aura expiré. ;)