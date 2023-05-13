---
title: Analyse des logs avec Goaccess
date: 2022-01-30

taxonomies:
  tags:
    - note
    - goaccess
    - ubuntu
    - apache
  categories:
    - système
---

# Mise en place des statistiques d'accès web avec Goaccess

La solution prévue à l'origine était avec Awstats, sauf que… bin non. On a donc rapidement basculé sur Goaccess parce que c'est plus sexy, fait plus de boulot et que c'est bien plus facile à mettre en œuvre.

Le serveur tourne sur un Ubuntu 20.04.

## L'utilisateur

En premier lieu, la création l'utilisateur qui va avoir accès au log du serveur Apache et bosser convenablement suffisamment de droits. Les logs d'Apache appartenant à root:adm, on va utiliser root^W le groupe adm. Il faut que notre utilisateur appartient à ce groupe, on va utiliser systemd-sysusers pour créer l'utilisateur.

On ajoute un fichier goaccess.conf dans le répertoire /usr/lib/sysusers.d

    u goaccess - "Goaccess user" /var/lib/goaccess /bin/bash
    m goaccess adm

On lance la création de l'utilisateur

    systemd-sysusers goaccess.conf

On crée son répertoire d'accueil, puis on corrige l'appartenance (note: n'est-ce pas fait par systemd ?).

    mkdir /var/lib/goaccess
    chown goaccess: /var/lib/goaccess

On teste l'accès aux répertoires des logs.

    setpriv --reuid=goaccess --regid=goaccess --init-groups ls /var/log/apache2/

On peut aussi utiliser la commande suivante

    sudo -iu goaccess ls /var/log/apache2/

Tout va bien. :)

## La tâche planifiée avec systemd

N'ayant pas d'expérience avec Goaccess, j'ai lancé l'analyse des logs toutes les heures. Mauvaise idée, car Goaccess duplique autant de fois les entrées qu'il les scanne. La génération se fera chaque jour, suite à la rotation des logs, en utilisant le fichier log de la veille.

Le service - `/etc/systemd/system/goaccess.service`

    [Unit]
    Description=Update goaccess report

    [Service]
    Type=oneshot
    User=goaccess
    Group=goaccess
    ExecStart=/usr/bin/goaccess /var/log/apache2/downloads.access.log.1 -o /var/www/stats/index.html --log-format=COMBINED --static-file=.iso --load-from-disk --keep-db-files --db-path=/var/lib/goaccess

Le timer - `/etc/systemd/system/goaccess.timer`

    [Unit]
    Description=Update goaccess report daily

    [Timer]
    OnCalendar=*-*-* 00:01:00
    Persistent=true

    [Install]
    WantedBy=timers.target

On active le tout 

    systemctl enable --now goaccess.timer

## La rotation

Goaccess construit sa base de données et l'alimente en continu. Pour avoir des statistiques sur une période donnée -- un mois, par exemple -- il faut réinitialiser la base et sauvegarder le fichier HTML généré avec un nom horodaté.

Service - `/etc/systemd/system/goaccess-rotate.service`

    [Unit]
    Description=Rotate goaccess report

    [Service]
    Type=oneshot
    User=goaccess
    Group=goaccess
    ExecStart=/usr/local/bin/rotate-goaccess-log.sh

Timer - `/etc/systemd/system/goaccess-rotate.timer`

    [Unit]
    Description=Rotate goaccess report

    [Timer]
    OnCalendar=*-*-1 00:05:00
    Persistent=true

    [Install]
    WantedBy=timers.target


Script de rotation - `/usr/local/bin/rotate-goaccess-log.sh`.

    #!/bin/bash

    # On travaille sur jour+1. Il nous faut la date de la veille.
    DATE=$(date -d yesterday +"%Y%m")
    DB_PATH=/var/lib/goaccess
    HTML_PATH=/var/www/stats/

    mkdir ${DB_PATH}/${DATE}

    mv ${DB_PATH}/*tcb ${DB_PATH}/${DATE}
    cp ${HTML_PATH}/index.html ${HTML_PATH}/index-${DATE}.html