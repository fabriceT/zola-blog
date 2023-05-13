---
title: Sauter d'une distribution Linux à l'autre sans bouger de son siège avec distrobox
date: 2022-04-21

taxonomies:
  tags:
    - note
    - conteneurs
    - podman
  categories:
    - système
---

[distrobox](https://github.com/89luca89/distrobox) est une suite de scripts permettant de manipuler des conteneurs, docker ou podman, pour avoir plusieurs distributions utilisables sur son système. C'est assez proche de WSL sur Windows où il vous est possible de faire fonctionner plusieurs distributions Linux en même temps sur le même système.

La méthode « classique » était de créer une machine virtuelle, de créer des partages et de consommer du CPU. Les conteneurs sont une solution beaucoup plus légère, de plus distrobox monte des partages sur le conteneur afin retrouver votre environnement connu : vos fichiers seront accessibles, et vous aurez l'impression d'être sur la machine hôte.

Des exemples d'utilisation : 
- Vous ne voulez ou ne pouvez  pas installer un programme sur votre distribution : nouveau conteneur de la distribution de choix, installation du programme sur celle-ci et hop…
- Vous utilisez Archlinux (btw) et voulez continuer à manipuler une autre distribution parce que c'est ce qu'il y a sur vos serveurs (Almalinux, Centos).
- Vous devez utiliser plusieurs versions d'un même programme.

## Création et utilisation d'un conteneur

Son utilisation est simple. On va « installer » Amazon Linux sur un ordinateur (ArchLinux).

    arch$ uname -a
    Linux arsinoe 5.17.4-arch1-1 #1 SMP PREEMPT Wed, 20 Apr 2022 18:29:28 +0000 x86_64 GNU/Linux
    arch$ distrobox-create --image public.ecr.aws/amazonlinux/amazonlinux:2022 --name awslinux
    …
    arch$ distrobox-enter awslinux -- /bin/bash
    Starting container awslinux
    awslinux$ uname -a
    Linux awslinux.arsinoe 5.17.4-arch1-1 #1 SMP PREEMPT Wed, 20 Apr 2022 18:29:28 +0000 x86_64 x86_64 x86_64 GNU/Linux

Notez que je suis obligé de spécifier le shell avec `-- /bin/bash` car mon shell courant est fish. Inutile de le faire si vous utilisez bash.

## Export et utilisation d'une utilisation installée dans le conteneur

Il est également possible d'« exporter » une application. L'export consiste à créer un fichier .desktop avec la commande pour lancer le programme dans le conteneur. On va installer Gnumeric dans un conteneur Alpine.

    arch$ distrobox-create --image docker.io/library/alpine:latest --name lapine
    arch$ distrobox-enter lapine
    lapine$ su
    lapine# apk add gnumeric
    …
    lapine$ distrobox-export --app gnumeric

De retour sur notre distribution :

    arch$ cat ~/.local/share/applications/lapine-gnumeric.desktop 
    [Desktop Entry]
    Version=1.0
    Name=Gnumeric  (on lapine)
    …
    Exec=/usr/bin/distrobox-enter -T -n lapine -- "  gnumeric  %U"
    Icon=gnumeric
    …

Un nouvel icône est désormais présent sur Archlinux pour utiliser l'application gnumeric du conteneur lapine.

Il est également possible d'utiliser gnumeric à partir du conteneur alpine sans avoir exporté quoi que ce soit, il suffit de lancer la commande gnumeric dans un terminal « lapine ».

## Une distribution multi-distributions

Si vous utiliser un terminal ayant la possibilité de créer des profils, par exemple gnome-terminal, il vous est possible de créer plusieurs profils lançant chacun un conteneur différent. Il devient possible de changer de distribution en passant d'un onglet à l'autre. Une vidéo sur le site github de distrobox explique en détail la mise en place.

## Les autres commandes

Les autres commandes utilisables possèdent des noms suffisamment explicites :
  - distrobox-list
  - distrobox-stop
  - distrobox-rm

Les images et conteneurs sont bien sûr gérables avec podman (ou docker)