---
title: Utilisation de mots de passe en ligne de commande
date: 2021-04-24

taxonomies:
  tags:
    - note
    - linux
  categories:
    - système
    - sécurité
---
Polkit, anciennement PolicyKit, permet de définir des politiques d'exécution, d'autoriser un utilisateur à exécuter certaines parties d'un programme, contrairement à `sudo` qui permet d'exécuter la totalité d'un programme en escaladant les privilèges.

La configuration se réalise en deux parties :

- les actions (fichiers *.policy)
- les règles d'autorisation (fichiers *.rules)

## Configuration

La configuration est présente dans les répertoires suivants :

- `/etc/polkit-1/rules.d` et `/usr/share/polkit-1/rules.d` pour les règles locales ou les changements réalisés sur les règles installées avec la distribution.
- `/usr/share/polkit-1/actions` pour les actions distribuées avec les paquets de la distribution. 

Toute modification apportée dans `/usr/share/polkit-1/` pourra être écrasée par une mise à jour d'un paquet de la distribution.

## Les actions

Ce sont des fichiers XML. Pour reprendre l'exemple du Wiki Archlinux sur [Polkit](https://wiki.archlinux.org/'/'/usr/bin/gpartedusr/bin/gpartedindex.php/Polkit)

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE policyconfig PUBLIC
    "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
    "http://www.freedesktop.org/software/polkit/policyconfig-1.dtd">
    <policyconfig>

    <action id="org.archlinux.pkexec.gparted">
        <message>Authentication is required to run the GParted Partition Editor</message>
        <icon_name>gparted</icon_name>
        <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/gparted</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
    </action>

    </policyconfig>

La section `defaults` comporte les mots clefs suivants :

- `allow_inactive`: généralement les sessions distantes (SSH ,VNC…).
- `allow_active`: les sessions ayant place sur un TTY ou sur X.
- `allow_any`: toutes les sessions précédentes.

Chaque mot clef possède les valeurs suivantes possibles :

- `no`: L'utilisateur ne peut pas réaliser l'action. Rien ne se passera.
- `yes`: L'utilisateur est autorisé, aucune authentification n'aura lieu.
- `auth_self`: Authentification est requise, l'utilisateur n'aura pas à être un administrateur.
- `auth_admin`: Authentification en tant qu'administrateur est requise.
- `auth_self_keep`: Pareil que `auth_self`, comme avec sudo, l'autorisation dure quelques minutes.
- `auth_admin_keep`: Pareil `auth_admin`, comme avec sudo, l'autorisation dure quelques minutes.

Le mot clef `annotate` permet de définir un dictionnaire clef/valeur. Les clefs possibles sont les suivantes :

- org.freedesktop.policykit.exec.path — spécifie le chemin du programme à lancer
- org.freedesktop.policykit.exec.allow_gui — permet d'avoir une interface graphique
- org.freedesktop.policykit.exec.argv1 — spécifie le premier argument du programme. Par exemple, pour un programme en python `/usr/bin/python /usr/local/bin/test.py` donne path = `/usr/bin/python` et argv1 = `/usr/local/bin/test.py`.
- org.freedesktop.policykit.imply — l'utilisateur autorisé pourra également réaliser l'action indiquée.
- org.freedesktop.policykit.owner.

Configuration en détail : https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html

## Les règles

Ce sont des fichiers dont la syntaxe est du javacript (ECMA-262 édition 5) ; XML et Javascript, yeah !

Les règles sont lues dans `/etc`, puis `/usr` et triées par ordre numérique. En cas de fichiers nommés de manière identique, celui dans `/etc` est prioritaire.

Les répertoires `/etc/polkit-1/rules.d` et `/usr/share/polkit-1/rules.d` sont monitorés, tout changement dans une règle sera reporté automatiquement.

On reprend l'exemple du Wiki Archlinux.

    /* Allow users in admin group to run GParted without authentication */
    polkit.addRule(function(action, subject) {
        if (action.id == "org.archlinux.pkexec.gparted" &&
            subject.isInGroup("admin")) {
            return polkit.Result.YES;
        }
    });

On autorise l'exécution avec `pkexec` si l'utilisateur est dans le groupe `admin`.

### Les fonctions dans les règles

- `void addRule(polkit.Result function(action, subject) {…});`
- `void addAdminRule(string[] function(action, subject) {…});`
- `void log(string message);`
- `string spawn(string[] argv);`

#### Paramètre action

- Propriétés:
  - `string id`
  - `string program` - org.freedesktop.policykit.exec.path ?
  - `string user.display`
  - `string command_line` - org.freedesktop.policykit.exec.path ?
  - `string user` - utilisateur de destination
  - `polkit.gettext_domain`
  - `string user.gecos`

- Méthode:

  - `string lookup(string key);`: retourne `undefined` si la valeur `key` n'est pas trouvée dans la valeur de l'action

#### Paramètre subject

- Propriétés :
  - int pid - ID du processus.
  - string user - Nom de l'utilisateur.
  - string[] groups - Liste de groupes auxquels appartient l'utilisateur.
  - string seat - Le `seat` auquel le `subject` est rattaché - vide si ce n'est pas un siège local.
  - string session - La session à laquelle l'utilisateur est attaché.
  - boolean local -  `true` si le siège est local.
  - boolean active - `true` si la session est active.

- Méthodes :

  - `boolean isInGroup(string groupName);` : utilisé pour vérifier si `subject` est dans le groupe `groupName`.
  - `boolean isInNetGroup(string netGroupName);` : utilisé pour vérifier si `subject` est dans le groupe réseau `netGroupeName`.

#### Retour polkit.Result

    polkit.Result = {
        NO              : "no",
        YES             : "yes",
        AUTH_SELF       : "auth_self",
        AUTH_SELF_KEEP  : "auth_self_keep",
        AUTH_ADMIN      : "auth_admin",
        AUTH_ADMIN_KEEP : "auth_admin_keep",
        NOT_HANDLED     : null
    };

## Cas pratique

Imaginons que l'on souhaite mettre en place une politique de sécurité dans laquelle les utilisateurs appartenant au groupe `wheel` peuvent manipuler un jeu de services systemd avec les commandes `start`, `stop`, `reload` et `restart`.

La commande `pkaction | grep systemd` nous donne l'action que l'on va configurer : `org.freedesktop.systemd1.manage-unit-files`.

Attention : un code complexe peut faire planter polkit. :/

    polkit.addRule(function(action, subject) {
        // On effectue un filtre sur l'action et les prérequis utilisateurs.
        if (action.id != "org.freedesktop.systemd1.manage-unit-files" ||
            !subject.local || !subject.active || !subject.isInGroup("wheel") ) {
                return polkit.Result.NOT_HANDLED;
        }

        // on récupère les infos.
        //    https://github.com/systemd/systemd/commit/88ced61bf9673407f4b15bf51b1b408fd78c149d
        var verb = action.lookup("verb");
        var unit = action.lookup("unit");

        // J'aime pas les multiconditions qui n'en finissent pas.
        isVerbAllowed = (verb == "start" || 
                         verb == "stop" || 
                         verb == "restart" || 
                         verb == "reload");
                        
        isUnitAllowed = (unit == "lighttpd.service" ||
                         unit == "usbguard.service");

        if (isVerbAllowed && isUnitAllowed) {
                return polkit.Result.YES;
        }

        return polkit.Result.NOT_HANDLED;
    });

## Programmes de polkit

### pkexec

Le programme pkexec permet de lancer une application avec des droits d'administration si une configuration est présente pour cette dernière et que l'utilisateur est de ceux autorisés pour exécuter l'action.

### pkaction

Listes les actions enregistrées.

    $ pkaction

Affiche les informations d'une action en particulier.

    $ pkaction -v -a org.libvirt.api.secret.save
    description:       Save secret
    message:           Saving secret configuration requires authorization
    vendor:            Libvirt Project
    vendor_url:        https://libvirt.org
    icon:              
    implicit any:      no
    implicit inactive: no
    implicit active:   no