---
title: Chercher des données personnelles avec ClamAV et YARA
date: 2022-05-09

taxonomies:
  tags:
    - note
    - yara
    - clamav
  categories:
    - système
---
YARA est un outil permettant de rechercher, et trouver, des occurrences permettant d’identifier des données dans un fichier. Ces données peuvent être la signature d’un malware, une séquence d’initialisation d’un algo de chiffrement, packer… Toute sorte de données. Bref, c’est un outil très intéressant.

Ceux qui ont eu à gérer un serveur de fichiers dans une entreprise se sont vite rendu compte que cela pouvait partir en grand n’importe quoi. La zone permettant l’échange de fichiers entre service a très souvent tendance à partir en foire au gros n’importe quoi : données RH, données personnelles, mot de passe… Il faut avoir l’œil, car toutes les raisons sont bonnes pour faciliter l'échange entre personnes.

RGPD étant un mot bien compliqué à écrire, nous allons ici faire la chasse aux données personnelles avec des règles YARA et ClamAV. Oui, il est possible des signatures virales personnelles avec ClamAV. En plus ce dernier va inspecter les archives et autres formats complexes.

Partons à la chasse aux adresses mails et aux numéros de téléphones.

## Les règles YARA

Avant de commencer, peut-être voulez-vous jeter un petit coup d'œil à la [documentation YARA](https://yara.readthedocs.io/en/latest/) ? Il y a des restrictions sur les [règles YARA comprises par ClamAV](https://docs.clamav.net/manual/Signatures/YaraRules.html). Faîte gaffe !

### L'adresse mail

Généralement, elle consiste en `prenom.nom@fai.tld`. On va faire simple en détectant certains fournisseurs d'adresse mail pour particuliers. De toute façon, les adresses mails circulent souvent en troupeau. Détectez en une, vous aurez un emplacement de choix où d'autres données personnelles auront fait leur nid.

    rule mail_perso
    {
        strings:
            $ = "@aol.com" nocase
            $ = "@caramail.com" nocase
            $ = "@gmail.com" nocase
            $ = "@gmx.fr" nocase
            $ = "@hotmail.fr" nocase
            $ = "@icloud.com" nocase
            $ = "@laposte.net" nocase
            $ = "@orange.net" nocase
            $ = "@outlook.fr" nocase
            $ = "@outlook.com" nocase
            $ = "@sfr.fr" nocase
            $ = "@yahoo.fr" nocase
            $ = "@wanadoo.fr" nocase
        condition:
            any of them
    }

On demande ici à ClamAV de trouver au moins une occurrence de chaînes de caractères dans celles à trouver, sans se soucier de la casse.

### Le numéro de téléphone

C'est la plaie, les gens écrivent les numéros de téléphone d'une manière généralement arbitraire. On va donc rechercher :

* Un ensemble de 5 groupes de 2 chiffres
* Les groupes sont séparés par un caractère ou non
* Le premier groupe commence par un 0
* Un espace est présent avant le premier groupe
* Un point ou un espace à la fin de dernier groupe.

Ce n'est pas fiable, on ramasse un peu n'importe quoi. Cela permet tout de même de filtrer

    rule phone_privacy
    {
        strings:
            $phone= /s0[0-9].?[0-9]{2}.?[0-9]{2}.?[0-9]{2}.?[0-9]{2}(s|.)/
        condition:
            $phone
    }

## La détection

On regroupe les 2 règles dans un fichier avec l'extension .yara, ou on utilise le mot clef `include`, puis on lance le scan

    clamscan -d privacy.yara -r -i tests/
    Loading:     0s, ETA:   0s [========================>]        2/2 sigs
    Compiling:   0s, ETA:   0s [========================>]       40/40 tasks

    ./tests/test.docx: YARA.phone_privacy.UNOFFICIAL FOUND
    ./tests/test.xlsx: YARA.mail_privacy.UNOFFICIAL FOUND

Et hop, une belle liste de fichiers à scruter.
