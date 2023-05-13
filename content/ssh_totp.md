---
title: TOTP avec SSH
date: 2020-06-14
update: 2020-06-14

taxonomies:
  tags:
    - note
    - ssh
    - totp
  categories:
    - système
    - sécurité
---
## Qu'est que ce le TOTP

TOTP (Time-base One time Password) est un système permettant d'avoir une protection supplémentaire sur l'authentification. Un mot de passe supplémentaire (token ou jeton d'authentification) est généré à partir d'un secret et le temps. Il faut donc impérativement que la machine sur laquelle vous allez vous connecter et la machine qui va générer le jeton soient synchronisées.

Pour faciliter l'authentification et réduire les problèmes qu'il pourrait découler de machines non synchronisées, les jetons sont générées toutes les 30 secondes. De plus, il est possible d'utiliser des jetons antérieurs dans une limite qui sera à définir.

Comme générateur de TOTP, j'utilise principalement « Microsoft Authenticator » sur Android. Quand lil est possible de récupérer le secret, j'aime bien l'ajouter dans KeepassXC qui possède un générateur TOTP.

## Préparation du système

On installe le paquel libpam-google-authenticator

```bash
$ sudo pacman -S libpam-google-authenticator
```

Puis on modifie la règle PAM pour sshd (généralement `/etc/pam.d/sshd`) afin d'y ajouter le composant google-authenticator à l'aide la ligne suivante :

    auth required pam_google_authenticator.so nullok

Le paramètre `nullok` permet de valider l'authentification avec PAM si pam_google_authenticator échoue, c'est à dire que TOTP n'a pas été configuré pour l'utilisateur.

## Configuration du TOTP

L'option correspondante dans le fichier de configuration sera placée entre parenthèses, comme ceci (`CONFIGURATION`).

On configure le TOTP en lançant la commande : `google-authenticator`

    Do you want authentication tokens to be time-based (y/n) y

Oui, on ne veut du TOTP (`TOTP_AUTH`). Dans le cas contraire, il s'agit de HOTP. 

On scanne le QR code avec son téléphone portable et son application TOTP. Puis, on valide en saisissant le jeton affiché sur l'application.

    Your new secret key is: 5P4XMJHSTVICHDXSUNN5N7K7LU
    Enter code from app (-1 to skip): 450996
    Code confirmed
    Your emergency scratch codes are:
    53582982
    60389735
    70237341
    66203022
    84077072

Notez qu'il y a des codes permettant de se connecter en cas de problème.

Si le teste échoue, c'est probablement un problème de synchronisation de temps. Systemd propose par défaut le service systemd-timesyncd pour mettre à jour l'horloge de l'ordinateur. On regarde s'il est activé avec : `systemctl is-enabled systemd-timesyncd`.

Dans le cas où le service n'est pas activé, on le lance et l'active avec `sudo systemctl enable -now systemd-timesyncd`.

Suite de la configuration

    Do you want me to update your "/home/rundeck/.google_authenticator" file? (y/n) y

C'est oui parce qu'on veut le configurer, m'enfin...

    Do you want to disallow multiple uses of the same authentication
    token? This restricts you to one login about every 30s, but it increases
    your chances to notice or even prevent man-in-the-middle attacks (y/n) y

On limite le nombre de connexions avec le même code généré (`DISALLOW_REUSE`).

    By default, a new token is generated every 30 seconds by the mobile app.
    In order to compensate for possible time-skew between the client and the server,
    we allow an extra token before and after the current time. This allows for a
    time skew of up to 30 seconds between authentication server and client. If you
    experience problems with poor time synchronization, you can increase the window
    from its default size of 3 permitted codes (one previous code, the current
    code, the next code) to 17 permitted codes (the 8 previous codes, the current
    code, and the 8 next codes). This will permit for a time skew of up to 4 minutes
    between client and server.
    Do you want to do so? (y/n) n

Si l'horloge de la machine est synchronisée, il est inutile de répondre oui. Dans le cas contraire, cela permet d'avoir une fenêtre plus large que celle des 3 codes par défault (`WINDOW_SIZE 17`). Plus la fenêtre sera réduite moins le temps imparti pour générer le code par force brute sera grand.

    If the computer that you are logging into isn't hardened against brute-force
    login attempts, you can enable rate-limiting for the authentication module.
    By default, this limits attackers to no more than 3 login attempts every 30s.
    Do you want to enable rate-limiting? (y/n) y

On répond oui pour réduire le nombre de tentatives de connexion possible pendant 30 secondes (`RATE_LIMIT 3 30`).

## Le fichier de configuration

Nous venons de créer le fichier de configuration pour libpam-google-authenticator, regardons-le :

```
$ cat .google_authenticator
OUBIH3FDLTOO5RZ6HUGBQ5ENFE
" RATE_LIMIT 3 30
" DISALLOW_REUSE
" TOTP_AUTH
87258672
63935529
20761921
24784026
48017194
```

On distingue 3 blocs dans ce fichier :

* le secret
* les options
* les codes d'urgence.

## Mot de la fin

Je recommande les lectures suivantes :

* l'excellent article de DigitalOcean sur la [configuration de TOTP sur Centos7](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-centos-7).
* [TOTP sur Wikipedia](https://en.wikipedia.org/wiki/Time-based_One-time_Password_algorithm)
* [Les facteurs d'authentification](https://fr.wikipedia.org/wiki/Facteur_d%27authentification)