---
title: Charm, ouvrez la boîte vers vos machines
date: 2023-12-03

taxonomies:
  tags:
    - note
    - database
    - partage
    - système de fichier
    - cloud
  categories:
    - cli
---

Charm est un couteau suisse des données distribuées. Il permet de partager des fichiers, ainsi que des données via une base de données clefs / valeurs. Il permet accessoirement de chiffrer et déchiffrer de manière symétrique des données.

Charm est créé par [Charmbracelet](https://charm.sh/), une société qui écrit des utilitaires et bibliothèques sympathiques permettant de rendre plus sexy les outils en ligne de commande.

## Le principe de Charm

Charm est un programme pouvant être utilisé en tant que client et en tant que serveur. Par défaut, il agira en tant que client et utilisera un serveur fourni par Charmbracelet pour y stocker ses données.

La connexion se fait à l'aide du protocole SSH d'une façon assez peu commune : il n'y a pas de compte à créer, le client va générer une clef SSH qui va servir à vous identifier. Si votre clef n'est pas connue sur le serveur alors un nouvel espace sera créé et attaché à cette clef.

Il est possible d'attacher d'autres clefs à cet espace en exécutant la commande `charm link`, puis en copiant le code résultant sur la machine que vous voulez lier.

## La base de données

Charm intègre une base de données de type clef / valeur. Le principe n'est pas différent des autres bases de données de ce type.

```bash
# On ajoute une entrée, puis l'affiche
$ charm kv set hello world!
$ charm kv get hello
world!
# On liste les clefs et valeurs (-k ou -v pour afficher uniquement la clef ou la valeur)
$ charm kv list
hello	world!
# suppression
$ charm kv delete hello

```

Comme on est sur du stockage sur le cloud, avec une copie de la base de données en local, il est possible de réaliser des opérations de synchronisation de la base. On envoie les données locales sur le cloud avec `charm kv sync` ou on écrase la base locale avec celle sur le cloud avec `charm kv reset`.

Charmbaracelet propose un autre utilitaire pour faire de la base de données clef / valeur: [skate](https://github.com/charmbracelet/skate). Il s'appuie sur Charm et permet d'utiliser plusieurs bases de données.

## Le système de fichiers

Charm permet de réaliser des opérations sur un pseudo-système de fichiers (créer, supprimer, lister). Son utilisation reste également très simple.

Copie d'un fichier local vers un répertoire sur le serveur Charm :

```bash
charm fs cp ~/.ssh/id_rsa.pub charm:/test/ssh/id_rsa.pub
```

Liste des fichiers et répertoire présents :

```bash
$ charm fs ls charm:/
 drwxr-x---   90 Nov  5 14:30 charm.sh.skate.default
 drwxr-x--- 4096 Dec  3 16:04 charm.sh.kv.user.default
 drwx------   52 Dec  3 16:22 test

```

Suppression d'un répertoire :

```bash
charm fs rm charm:/test/
```

On peut aussi faire un `cat` ou un `tree`.

## Héberger un serveur Charm

Cela se fait simplement en exécutant `charm serve` et en définissant chez les clients la variable d'environnement `CHARM_HOST` pour qu'elle contienne le nom ou l'adresse IP du serveur Charm.
