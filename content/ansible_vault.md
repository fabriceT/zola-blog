---
title: Débloquer automatiquement le vault d'ansible
date: 2024-10-08

taxonomies:
  tags:
    - note
  categories:
    - ansible

---

Je ne suis pas fan du vault d'ansible, ni des mots de passe. C'est donc avec une
grand intérêt que j'ai découvert que le configuration d'Ansible permettait
d'exécuter un script à la place d'un fichier contenant le mot de passe du vault.

Si le fichier `ansible.cfg` est situé dans `/etc/ansible`, alors script devra se
trouver dans le même répertoire.

```ini
vault_password_file=vault-sops.sh
```

Vu qu'il n'est pas possible d'exécuter une commande, le script sera principalement
une simple enveloppe de la commande qui permettra de récupérer le mot de passe
puisque Ansible va directement récupérer la sortie du script.

## Sops

```shell
#!/bin/bash

sops -d /etc/ansible/ansible-vault-password.txt
```

### libsecret

```shell
#!/bin/env bash

secret-tool lookup application ansible
```
