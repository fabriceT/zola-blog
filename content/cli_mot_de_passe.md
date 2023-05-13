---
title: Utilisation de mots de passe en ligne de commande avec Gnome-keyring
date: 2020-08-22

taxonomies:
  tags:
    - note
    - gnome-keyring
  categories:
    - sécurité
    - cli
---
En lisant [une documentation sur l'utilisation du coffre fort d'Ansible](https://www.unicoda.com/?p=4213), je suis tombé sur l'utilisation d'un script pour ouvrir automatiquement le coffre via un script shell. N'utilisant pas `pass` mais KeepassXC, je me suis demandé comment récupérer une valeur dans la base de données.

KeepassXC fourni un utilitaire `keepassxc-cli` pour réaliser des opérations dans la base de données des mots de passe, ce n'est cependant pas ce que je vais utiliser pour le moment (voir le [billet associé](/keepassxc-cli/)). :p 

Mon bureau étant Gnome, un autre gestionnaire de mot de passe est déjà présent pour ce bureau : `gnome-keyring`. C'est lui qu'on va utiliser puisque le mot de passe ne sera jamais partagé entre d'autres machines.

## libsecret ##

Libsecret est le backend de gnome-keyring, il fournit le programme `secret-tool`.

Pour créer une entrée dans la base de données de gnome-keyring :

    secret-tool store --label='Ansible Vault Password' application ansible
    password:

Pour afficher le mot de passe stocké : 
  
    secret-tool lookup application ansible.
    XXXXXX

Mais pourquoi "application ansible" ?

Le man indique que l'option `add` prend comme arguments `attribute value ...`, ce qui est obscur. On va creuser avec la fonction `search`.

    secret-tool search --all application ansible                                                                                                   
    [/org/freedesktop/secrets/collection/login/268]
    label = Ansible Vault
    secret = XXXXXXXX
    created = 2020-08-22 13:49:15
    modified = 2020-08-22 13:49:15
    schema = org.freedesktop.Secret.Generic
    attribute.application = ansible

En fait, c'est relativement simple malgré une écriture pas naturelle.

Notre entrée est visible dans gnome-keyring lorsqu'on utilise Seahorse.

## KeepassXC

Il faut soit entrer le mot de passe de la base de données, soit récupérer le mot de passe qu'on aura préalablement stocké dans libsecret.

On récupère le mot de passe, par exemple dans un script (c'est fish qui est utilisé ici)

    set pass=(secret-tool lookup application keepassxc)

On récupère ensuite le mot de passe.

    echo $pass | keepassxc-cli show  /home/phab/Sync/Passwords.kdbx /Infra/ansible -a Password 2> /dev/null

Perso, je préfère la première solution.