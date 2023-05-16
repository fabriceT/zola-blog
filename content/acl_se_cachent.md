---
title: Les ACL se cachent pour mourir
date: 2021-10-21

taxonomies:
  tags:
    - note
  categories:
    - système
---

Il y a, au boulot, une CentOS qui fait office de serveur de fichiers. La configuration de samba est « historique » avec des partages créés selon une organisation d’il y a au moins en une vingtaine d’années. Bien qu'il ne reste plus grand monde du moment de sa mise en place, il est impossible de restructurer tout cela par esprit de conservatisme parce que les utilisateurs se sont adaptés [tant bien que mal] à la situation. Chaque changement profond tendrait vers encore plus le mal. Bref, un serveur de fichiers comme il en existe tant.

La société a évolué, des personnes ont changé de services rendant obsolètes les partages créés pour répondre à des besoins depuis longtemps oubliés. Devant les besoins ponctuels d’échange, un partage d’accès libre temporaire a été créé il y a une huitaine d’années. J’aime bien l’appeler une TAZ, hormis que le temporaire reste une notion hypothétique. On y trouve de tout : des informations personnelles (« allô ! RGPD, cela vous dit quelque chose ? ») ou des espaces de travail qui devrait se trouver dans des partages restreints dédiés aux services. Lorsqu’on explique que tout le monde a accès en lecture et écriture, modifier à sa guise ces documents, tout cela est rapidement balayé de la main parce qu’on est pas venu pour ça et que c'est pratique.

Mais que viennent faire les ACL ? Comme certains peuvent le supposer, ce partage est devenu une zone libre où il a fallu mettre place des restrictions. Des documents du CSE ont fini par arriver sur cette TAZ un jour de COVID, il a donc fallu mettre en place des ACL pour réduire l’accès à ce répertoire. Je n’ai plus de souvenir de comment c’est arrivé ; le cerveau arrive à faire des choses assez étranges pour se protéger.

Bien plus tard, je retouche la configuration de samba pour serrer un tour de vis au niveau de la sécurité. La TAZ était configurée en tant que partage public ouvert à tout le monde, même aux invités. Je change ça pour limiter aux utilisateurs du domaine, et met l’unité organisationnelle de l’informatique comme administrateur du bazar.

Encore plus tard, une autre demande impliquant des ACL rentre dans le jeu. Cette fois-ci, il faut limiter l’accès en écriture à la majorité d’un service sur un répertoire dans le partage qui lui est dédié.*OK, faites ce que vous voulez chez vous, on est pas là pour vous apprendre à travailler*. Un collègue reprend ce que j’ai fait sur les ACL de la TAZ sauf que cela ne fonctionne plus. Bordel de manchot ! Une mise à jour a mis le dawa ?! Pourtant, tout semble OK dans la configuration. Le répertoire du CSE n’étant plus touché depuis un an, il se peut que personne ne s’est rendu compte de la supercherie.

On a cherché, bien cherché. Puis, je me suis rappeler de la sécurisation sur la TAZ et que − foutre Dieu ! − les membres du groupe administrateur du partage se contrefichent des ACL. On a donc cherché à résoudre un problème qui n’existait pas. J’hésite depuis à mettre des alias :

* `setfacl` = `setfuckingacl`
* `getfacl` = `getfuckingacl`.
