---
title: Débloquer automatiquement le vault d'ansible
date: 2023-10-08

taxonomies:
  tags:
    - note
  categories:
    - ansible

---

Je ne suis pas spécialement fan d'Ansible Vault, ni des mots de passe qu'on doit saisir, c'est donc avec un grand intérêt que j'ai découvert que la configuration d'Ansible permettait d'exécuter un script à la place d'un fichier contenant le mot de passe du coffre. Ansible se charge de capturer la sortie du script et de la traiter comme si on avait fait un `cat <vault_password.txt>`.

```ini
vault_password_file=vault-unlock.sh
```
Dans l'exemple ci-dessus, le script appelé doit être situé dans le répertoire dans lequel se situe le fichier `ansible.cfg`.

Étant donné qu'il n'est pas possible d'exécuter directement une commande, le script sera principalement une enveloppe autour de la commande permettant d'afficher le mot de passe.

## Exemples de scripts

### Sops

SOPS est une sorte de GPG allégé, il permet de chiffrer en utilisant des clefs privées.

```bash
#!/bin/env bash

sops -d /etc/ansible/ansible-vault-password.txt
```

### libsecret

Libsecret est le système de stockage de secrets de Gnome.

```bash
#!/bin/env bash

secret-tool lookup application ansible
```
