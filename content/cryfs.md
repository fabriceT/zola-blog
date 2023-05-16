---
title: "Chiffrer ses données avec CryFS"
date: 2022-12-08

taxonomies:
  tags:
    - note
    - cryptographie
  categories:
    - système
---

J'ai pour habitude de chiffrer les données qui n'ont pas à finir dans les mains de n'importe qui (par exemple, scan de documents d'identité). Plusieurs solutions se sont suivies ([encfs](https://github.com/vgough/encfs), [gocryptfs](https://nuetzlich.net/gocryptfs/)), c'est désormais, c'est au tour de CryFS de faire son intégration dans ma solution de chiffrement.

Dans les points qui m'ont fait choisir :

* Utilisation de [scrypt](https://en.wikipedia.org/wiki/Scrypt) pour déchiffrer la partie configuration. Selon la documentation, l'algorithme scrypt rend l'attaque par force brute très gourmande ;
* Découpage des fichiers et de l'arborescence en blocs de taille homogène. Les solutions comme gocryptfs chiffrent les fichiers et masquent les noms, il reste tout de même possible de déterminer quelle est la nature des fichiers, voire déterminer le contenu si les caractéristiques de profondeur de l'arborescence et nombre de fichiers, ainsi que leur ordre de grandeur sont connus. Il est impossible avec CryFS de savoir s'il y s'agit de 5 000 images ou d'un seul fichier vidéo qui sont chiffrés.

CryfS est très pratique pour stocker des données chez un hébergeur auquel vous avez peu confiance. Il existe une solution similaire multiplateforme : [cryptomator](https://cryptomator.org/)

Problème : on ne peut pas modifier à partir de deux points distincts des fichiers d'un même point stockage CryFS. Cela aura pour effet de créer des divergences dans ce stockage. Pour palier ce problème, les modifications doivent se faire à partir d'un seul point de montage où les données déchiffrées seraient partagées (SSH…)
