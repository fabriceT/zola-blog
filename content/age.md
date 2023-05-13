---
title: "Chiffrer des fichiers avec age"
date: 2023-02-02

taxonomies:
  tags:
    - note
    - cryptographie
  categories:
    - système
---
[Age](https://github.com/FiloSottile/age) est une solution moderne permettant de chiffrer des fichiers. C'est une solution plus légère que PGP, moins complète, mais également plus simple.

Age prend en charge le chiffrement symétrique et asymétrique. Par contre, il n'y a pas de possibilité de signer un document.

La création d'un couple de clef privée et publique et simple (ajoutez `-o key.asc` pour écrire dans un fichier `key.asc`.): 

    $ age-keygen 
    # created: 2023-02-03T09:16:01+01:00
    # public key: age1sq503wu8pr48t6yyuhdfcvkz6m0728nj8vx4yc8df9j3fuggsadsjhcmaq
    AGE-SECRET-KEY-1HX4RAVNH6JEXGZNW0NZNT4K3DG9GR2WGHDR867FMLZHW370FFQ2SQMCMF9

Allez, on commence.

## Chiffrement symétrique

On utilise une clef privée SSH pour chiffrer :

    $ age -e -i ~/.ssh/id_rsa -o outfile.enc infile

Il est possible d'utiliser l'option `-a` (`--armor`) pour rendre possible le transfert en mode texte du contenu.

On déchiffre de manière similaire avec l'option `-d`.

    $ age -d -i ~/.ssh/id_rsa -o outfile infile.enc

Lors du déchiffrement, `age` demandera la phrase de passe de la clef SSH utilisée.

## Chiffrement asymétrique

On indique les différents destinataires à l'aide de l'option `-r`. Il est possible d'utiliser les clefs publiques des destinataires, quelles soient de type age ou SSH.

    $ age -e -r age1ql3z…gcac8p -o outfile.enc infile

Afin de faciliter les manipulations avec plusieurs destinataires, il est possible d'utiliser l'option `-R` qui va prendre un fichier des clefs des destinataires

    $ cat recipients 
    age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
    ssh-rsa AAAAB3NzaC1yc2EAAAAD…qnNU4EeHWGz6ZKlhZkDp0t
    age1ctg0j84l4ar7aek6ln6352sc9gk5t2f35n3g4nkpmchharwxxdwqwj3lev

    $ age -e -R recipients.age -a -o outfile.enc infile

Chaque destinataire déchiffrera avec sa clef.

    $ age -d -i ~/.age/keys.asc infile # Pour clef age 

    $ age -d -i ~/.ssh/id_rsa infile # Pour SSH

## Conclusion

C'est un programme très facile à utiliser, non intrusif (un seul fichier exécutable à copier n'importe où) dont le système de clefs sert à [SOPS](https://github.com/mozilla/sops), une solution pour protéger les secrets.

Il y a cependant un point qui m'interpelle dans la documentation : il est possible d'utiliser plusieurs fois l'option `-i` pour utiliser plusieurs clefs. Cette partie m'échappe, car le chiffrement avec `-i` est un chiffrement symétrique, puis déchiffrer avec plusieurs clefs, ben… c'est étrange.

Un point gênant quant à l'utilisation de ce programme : Bien que l'on puisse utiliser des clefs privées pour chiffrer, il n'est pas possible de déterminer quelle clef a été utilisée pour chiffrer. Cela aura probablement permis la signature.