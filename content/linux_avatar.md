---
title: Avatar sous GNOME
date: 2020-10-11

taxonomies:
  tags:
    - gnome
    - linux
    - note
  categories:
    - système
---
L'avatar est l'image qui s'affiche lors de la connexion avec GDM, LightDM et autres xDM. On peut la choisir dans la section « utilisateurs » dans les paramètres de GNOME. Le fichier image choisi pour l'utilisateur sera présent dans le répertoire `/var/lib/AccountsService/icons` sous le nom de l'utilisateur.

Un avatar par défaut pourra être automatiquement choisi si un fichier image `.face` est présent dans le répertoire `$HOME` de l'utilisateur. Ce dernier utilisé de l'avatar et un fichier de configuration au nom de l'utilisateur sera créé dans le répertoire `/var/lib/AccountsService/users/`.

```ini
[User]
Language=
XSession=
Icon=/home/xtzY6/.face
SystemAccount=false
```

Le responsable de la création de ce fichier est [AccountsService](https://cgit.freedesktop.org/accountsservice/tree/).

GDM et le gnome-control-center s'appuient sur cette librairie pour récupérer des informations sur l'utilisateur, en créer ou les modifier.

AccountsService propose de [multiples fonctions pour récupérer des informations sur les utilisateurs](https://cgit.freedesktop.org/accountsservice/tree/src/libaccountsservice/act-user.h), par exemple `act_user_get_location` ou `act_user_get_email`. Ni GDM ou Gnome semblent en tenir compte.