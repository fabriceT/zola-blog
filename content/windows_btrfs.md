---
title: BTRFS sous Windows
date: 2020-09-15

taxonomies:
  tags:
    - note
    - windows
  categories:
    - système
---
Pour éviter de dupliquer des données en cas de machines avec dual boot Windows et Linux (par exemple, les mêmes dossiers partagés avec rsync sur Windows et Linux), il existe une solution pour monter un disque utilisant BTRFS.

On accède au sous-volume, cela prend en charge la compression (zlib, lzo et zstd), les ACL et encore tout un tas d'autres choses.

https://github.com/maharmstone/btrfs

Cela a l'air très cool.