---
title: "Ansible : Tester les rôles ansible avec molécule"
date: 2022-02-21T17:55:42+00:00
updated: 2022-02-21T17:55:42+00:00

taxonomies:
  tags:
    - note
  categories:
    - ansible
    - système
---

Paquets nécessaires sous Archlinux :

  - `molecule`
  - `molecule-podman` pour approvisionner une VM en utilisant Podman.

## Configuration

On crée un rôle utilisant `podman` comme fournisseur de VM

```bash
molecule init role acme.my_new_role --driver-name podman
```

On configure le conteneur qui va servir à notre test en éditant `molecule/default/molecule.yml`.

```yaml
platforms:
- name: ansible_test
  image: quay.io/almalinux/almalinux:9
  pre_build_image: true
```

## On lance le bouzin

Pour vérifier si cela fonctionne

```bash
molecule check
```
Pour faire converger le conteneur vers la configuration (après modification du rôle, sans relancer la chaîne complète en détruisant le conteneur)
```bash
molecule converge
```
Pour entrer dans le conteneur
```bash
molecule login
```

[Documentation](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1).
