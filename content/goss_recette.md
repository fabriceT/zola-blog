---
title: "Goss: Réaliser la recette d'un serveur"
date: 2022-02-21
updated: 2022-02-21

taxonomies:
  tags:
    - note
  categories:
    - système
---

Goss permet la vérification de l'état d'un serveur pour valider si ce dernier correspond à l'état désiré, par exemple avec Ansible.

le programme [goss](https://github.com/aelsabbahy/goss) permet de vérifier l'état d'un serveur à partir de spécifications (service, fichiers,...)

La configuration est réalisée à l'aide d'un fichier YAML (goss.yml). On peut cependant renseigner le fichier à l'aide du programme Goss.

Par exemple :

    goss add service sshd

On peut automatiquement générer les spécifications à partir de l'existant

    goss autoadd sshd

Ce qui va générer les contraintes pour le service, l'adresse d'écoute, l'utilisateur et groupe, le process en cours…
