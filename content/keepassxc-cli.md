---
title: Utilisation de keepassXC en ligne de commande
date: 2023-03-11

taxonomies:
  tags:
    - note
    - keepassxc
  categories:
    - sécurité
    - cli
---

Nous allons voir comment utiliser le programme `keepasspx-cli` pour réaliser des opérations sur les coffre-forts de base de données de mot de passe ou pour générer un mot de passe.

## Génération des mots de passe

KeepassXC est capable de générer des mots de passe selon la [méthode du lancer des dés](https://fr.wikipedia.org/wiki/Diceware) ou en générant des séquences de caractères de longueur désirée en puisant dans des classes de caractères.

### Lancers de dés (diceware)

On exécute un lancer de dés en utilisant un dictionnaire personnalisé (`-w`) et un nombre de mots défini (`-W`)

```bash
keepassxc-cli diceware -w mots.francais.frgut.txt -W 5
```

### Génération d'un mot de passe aléatoire

Génération d'une séquence de 12 caractères avec des caractères alphanumériques, en majuscule, en minuscule, spéciaux et extra.

```bash
keepassxc-cli generate --every-group -n -U -l -s -e -L 12
```

## Réaliser des requêtes

### Naviguer dans l'arborescence

On utilise l'option `ls`

```bash
keepassxc-cli ls ~/Passwords.kdbx Storage/Cloud
```

## Recherche dans la base de données

Cela est réalisé avec l'option `search`. Les termes recherchés sont définis dans la documentation [Searching the database](https://keepassxc.org/docs/KeePassXC_UserGuide.html#_searching_the_database). On y trouve également quelques exemples.

Pour afficher les entrées ayant un attribut `OTP` (celles qui ont le TOTP configuré)

```bash
keepassxc-cli search ~/Passwords.kdbx attr:otp
```

## Information complémentaire

La page man se trouve accessible [man keepassxc-cli](https://github.com/keepassxreboot/keepassxc/blob/develop/docs/man/keepassxc-cli.1.adoc)
