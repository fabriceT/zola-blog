---
title: "SOPS - Secret OPerationS"
date: 2023-02-03

taxonomies:
  tags:
    - note
    - cryptographie
  categories:
    - système
---

Si vous utilisez un programme de suivi de version pour vos projets, il vous est peut-être déjà arrivé de mettre dans ce suivi de version des identifiants, mot de passe et autres éléments qui n'auraient jamais dû être publiés. C'est con, c'est pourtant un truc qui arrive. :D

Pour réduire le risque lié à ce genre de problème, il est conseiller d'utiliser un coffre-fort (vault en langue d'Albion). Nous allons voir ici comment utiliser [SOPS](https://github.com/mozilla/sops) (Secrets OPerationS) de Mozilla.

SOPS utilise un système de clef publique et privée, il prend en charge PGP et age. PGP n'est pas conseillé et risque de ne plus être pris en charge. Nous n'aborderons donc que la gestion des secrets avec des clefs age.

Pour rappel, on génère son couple de clefs avec la commande

    age-keygen -o my-key.asc

Ce qui donne une clef privée de la forme suivante :

    # created: 2023-02-03T09:16:01+01:00
    # public key: age1sq503wu8pr48t6yyuhdfcvkz6m0728nj8vx4yc8df9j3fuggsadsjhcmaq
    AGE-SECRET-KEY-1HX4RAVNH6JEXGZNW0NZNT4K3DG9GR2WGHDR867FMLZHW370FFQ2SQMCMF9

La clef publique est indiquée. :D

## Chiffrement et déchiffrement

Comme age, il est possible d'avoir plusieurs récipiendaires lors du chiffrement d'un fichier ; Chaque récipiendaire pourra le déchiffrer avec sa clef privée.

On chiffre pour un destinataire (il suffit d'ajouter une autres clefs pour en ajouter un autre, ` --age age1...ds`)

    sops -e -age age1sq503wu8pr48t6yyuhdfcvkz6m0728nj8vx4yc8df9j3fuggsadsjhcmaq infile > outfile

On déchiffre

    sops -d outfile

Notes importantes:

* SOPS veut déchiffrer en utilisant la clef privée située à l'emplacement `$XDG_CONFIG_HOME/sops/age/keys.txt`. Il est possible de spécifier une autre clef en utilisant la variable d'environnement `SOPS_AGE_KEY_FILE`.
* SOPS peut s'emmêler les pinceaux lors du déchiffrement. C'est parce qu'il doit « comprendre » le format de fichier qu'il a chiffré. Ces formats sont YAML, JSON, ENV, INI et BINARY. Il faut donc que le format soit indiqué par l'extension du fichier ou explicitement spécifié avec les options `--input-type` et `--output-type`.

## Cas concrets

J'utilise mon Synology comme plate-forme docker. Vu qu'il y a des secrets dans la composition des conteneurs (mot de passe d'applications pour les mails, token JWT...), j'ai classiquement séparé les [fichiers docker-compose en deux parties](https://docs.docker.com/compose/environment-variables/set-environment-variables/) :

* un fichier d'environnement (`.env`) qui va comporter les variables
* le fichier docker-compose qui va prendre en compte les variables du fichier d'environnement dans la partie déclarative.

Les secrets seront stockés dans le fichier .env qui vont être ajoutés au gestionnaire de suivis. Ok, sauf que ça bloque au niveau sécurité puisque les données sont en clair. Ainsi, Il faut des fichiers d'environnement chiffrés qui vont pouvoir être utilisés par `docker-compose`.

L'idée serait de chiffrer les fichiers d'environnement, puis de les déchiffrer en fichiers `.env` avant l'appel à `docker-compose up`. SOPS offre une solution élégante pour répondre à cette problématique : exécuter une commande dans un environnement spécifique avec l'option `exec-env`.

Pour ma part, une commande lance `docker-compose` dans un environnement utilisateur configuré par SOPS et préservé par `sudo`.

    sops exec-env crypted.env "sudo -E docker-compose up -d"

On peut redire sur le `sudo` et le fait que cela tourne en `root`, je n'ai pas testé de mettre la couche docker en rootless sur le Synology.

Maintenant qu'il est possible de reconstruire le conteneur en utilisant des données chiffrées, il faut nous concentrer sur l'importance des données chiffrées puisque toutes n'ont pas toute la même importance. Le document chiffré peut contenir, par exemple, la version de l'image ou l'emplacement d'un volume. Il n'y a pas besoin de préserver la confidentialité pour une telle information. Souvenez-vous que SOPS comprend plusieurs formats de fichier ; Cela rend possible de chiffrer des informations au sein d'un fichier en ignorant d'autres. On sélectionne les sections à chiffrer, ou à exclure du chiffrement, avec les options `--(un)encrypted-suffix` et `--(un)encrypted-regex`.

La commande suivante permet d'ignorer les variables préfixées par `APP_`.

    sops -e --unencrypted-regex "^APP_" -age age1dw...s7hl .env > encode.env

Il est ainsi possible de voir apparaître en clair les valeurs de ces variables dans le fichier chiffré et apporter un certain confort visuel. Par contre, il n'est pas conseillé de modifier directement le fichier chiffré afin, par exemple, de mettre à jour la version de l'image puisqu'il y aurait détection de l'altération du fichier lors du déchiffrement ce qui bloquera SOPS. Ce comportement peut être modifié en utilisant l'option `--ignore-mac`.
