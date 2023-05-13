---
title: Certificats SSH pour les utilisateurs
date: 2023-04-30
taxonomies:
  tags:
    - SSH
    - note
  categories:
    - Sécurité
---

Nous avons vu précédemment comment mettre en place des certificats pour les hôtes,
nous allons voir comment faire de même pour les utilisateurs.

Le certificat SSH utilisateur permet une connexion à un hôte sans que la clef
publique de l'utilisateur n'ait été déployé sur l'hôte. Cela permet une gestion
simplifiée des accès lorsque le nombre de serveurs augmente.

## Création d'une autorité de certifications

Idem que pour les certificats d'hôtes.

```bash
ssh-keygen -a 256 -f ssh_user_ca -t ecdsa -C "CA User"
```

## Création du certificat

On va créer un certificat pour l'utilisateur possédant la clef publique `id_rsa-marcel.pub`
puisse se connecter en tant que marcel sur les hôtes.

```bash
ssh-keygen -I Marcel123 -s ssh_user_ca -h -n marcel -V +1w -z 1 id_rsa-marcel.pub
```

Cela va créer le certificat `id_rsa-marcel-cert.pub` qui devra être retourné à
l'utilisateur.

## Utilisation du certificat

### Chez l'utilisateur

L'utilisateur doit copier son certificat à côté de sa clef privée SSH. Le client le présentera
lors de la connexion.

### Sur les hôtes

Les hôtes devront pouvoir valider que le certificat a bien été délivré par l'autorité
de certification. Il est donc nécessaire de copier la clef publique du CA sur le
serveur, par exemple dans `/etc/ssh`, et ajouter la ligne suivant dans le
fichier `/etc/ssh/sshd_config` :

```
TrustedUserCAKeys /etc/ssh/ssh_user_ca.pub
```

Et on redémarre le service SSH avec `systemctl reload sshd`.
