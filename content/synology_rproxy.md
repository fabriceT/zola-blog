---
title: "NAS synology en reverse proxy"
date: 2020-10-08

taxonomies:
  tags:
    - note
    - synology
    - nginx
  categories:
    - système
    - réseau
---
Il existe moulte documentations sur utilisation d'un NAS Synology comme reverse proxy : panneau de configuration, « Application Portal », la moitié du travail est fait. Sauf qu'il y a pas mal de limitation dans ce qu'on peut configurer ; par exemple, pas moyen d'indiquer des restrictions sur les sections *location*.

Lorsqu'on passe par l'interface graphique, cela modifie le fichier `/etc/nginx/app.d/server.ReverseProxy.conf`. Toute tentative de modification de ce fichier pour y ajouter ses touches personnelles est vaine, car il est généré automatiquement et écrase le précédent fichier. Il va donc falloir trouver une alternative. Il est possible de lancer un conteneur avec nginx et faire la configuration à la main. C'est très DevOps mais pourquoi instancier un autre nginx alors qu'on peut utiliser l'existant ? On élimine ça.

La solution la plus sympathique trouvée, réside dans l'utilisation du répertoire `/etc/nginx/sites-enabled`. Il suffit de placer la configuration de votre site dans le répertoire `sites-enabled` et de relancer le service nginx. Comme on peut glisser subrepticement quelques erreurs dans la conf nginx du syno, je vous recommande de vérifier la conf avant de relancer nginx.

``` bash
# nginx – t
# systemctl reload nginx
```

Synology utilise Systemd depuis la version 7 de DSM. Avant, il fallait utiliser `synoservicectl --restart nginx` pour relancer le service.


Voilà.