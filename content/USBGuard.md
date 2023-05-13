---
title: USBGuard
description: Verrouillage des ports USB avec USBGuard
date: 2020-06-09
updated: 2023-02-23

taxonomies:
  tags:
    - "sécurité"
    - "linux"
---

[Usbguard](https://usbguard.github.io/) permet sécuriser une machine en limitant la possibilité d'y connecter des périphériques USB.

## Configuration initiale

La configuration d'USBGuard est située dans fichier `/etc/usbguard/usbguard-daemon.conf`.

Sous Archlinux, les règles d'autorisation sont écrites dans `/etc/usbguard/rules.conf` (cf directive `RuleFile`). Dès que le deamon démarre, il empêche tout accès à de nouveaux périphériques USB. Il est donc souhaitable de générer des règles par défaut avant de lancer le daemon sous peine de perdre des périphériques USB (Clavier où es-tu ?). Pour ce faire, on exécute la commande suivante :

```bash
# usbguard generate-policy > /etc/usbguard/rules.conf
```

L'ensemble des périphériques USB connectés seront alors explicitement autorisés sur la machine lors de l'exécution d'USBGuard.


## Autorisation d'un périphérique

Pour aider au diagnostic, on utilisera

```bash
# usbguard watch
```

Lors de l'ajout d'une clef USB, on voit apparaître les ligne suivantes

    [IPC] Connected
    [device] PresenceChanged: id=13
    event=Insert
    target=block
    device_rule=block id 0951:1666 serial "60A44C413CA0B17199760028" name "DataTraveler 3.0" hash "11OKC9VqBKHI5t0u74vHMIlJqHPpgO063wBmlnH2hn8=" parent-hash "9JszuPWESBEur6P34acG7ZtBUqRa6fRgdsma6hSNpOk=" via-port "2-2" with-interface 08:06:50 with-connect-type "hotplug"
    [device] PolicyChanged: id=13
    target_old=block
    target_new=block

La clef USB a été vue et bloquée (`block`).

### Ajout via la ligne de commande

Afin de pouvoir utiliser notre clef, il faut indiquer à `USBGuard` d'autoriser la clef. On peut le faire à l'aide de l'option `allow-device`.

```bash
$ usbguard allow-device id 0951:1666
```
La permission sera temporaire, il est possible de la rendre permanente avec `-p`.

```bash
$ usbguard allow-device id 0951:1666 -p
```

### Ajout dans la liste des règles

L'écriture de règles permet de définir plus précisément les conditions d'utilisation d'un périphérique. En effet, lors de l'ajout du périphérique via la ligne de commande, on garde l'ensemble des conditions, c'est-à-dire sur quel contrôleur le périphérique est autorisé. Dans le cas d'une clef USB, il semblera peut-être intéressant de ne pas limiter le port USB sur lequel la clef USB est autorisée.

La règle qui nous intéresse est présente dans l'affichage généré par `usbguard watch`, la modification majeure serait, évidemment, de remplacer `block` par `allow`, ce qui donne

    allow id 0951:1666 serial "60A44C413CA0B17199760028" name "DataTraveler 3.0" hash "11OKC9VqBKHI5t0u74vHMIlJqHPpgO063wBmlnH2hn8=" with-interface 08:06:50 with-connect-type "hotplug"

J'ai supprimé `parent-hash` et `via-port` dans la règle pour ne pas limiter la clef USB sur un port ou un contrôleur en particulier.

[Syntaxe pour les règles](https://usbguard.github.io/documentation/rule-language.html), aussi le
[Wiki Archlinux sur UBSGuard](https://wiki.archlinux.org/index.php/USBGuard)

On relance le daemon avec `systemctl restart usbguard` et on ajoute la clef.

    [IPC] Connected
    [device] PresenceChanged: id=22
    event=Insert
    target=block
    device_rule=block id 0951:1666 serial "60A44C413CA0B17199760028" name "DataTraveler 3.0" hash "11OKC9VqBKHI5t0u74vHMIlJqHPpgO063wBmlnH2hn8=" parent-hash "9JszuPWESBEur6P34acG7ZtBUqRa6fRgdsma6hSNpOk=" via-port "2-2" with-interface 08:06:50 with-connect-type "hotplug"
    [device] PolicyChanged: id=22
    target_old=block
    target_new=allow
    device_rule=allow id 0951:1666 serial "60A44C413CA0B17199760028" name "DataTraveler 3.0" hash "11OKC9VqBKHI5t0u74vHMIlJqHPpgO063wBmlnH2hn8=" parent-hash "9JszuPWESBEur6P34acG7ZtBUqRa6fRgdsma6hSNpOk=" via-port "2-2" with-interface 08:06:50 with-connect-type "hotplug"
    rule_id=9

La clef est maintenant autorisée.

Si on insère une clef USB de même modèle :

    [device] PresenceChanged: id=23
    event=Insert
    target=block
    device_rule=block id 0951:1666 serial "60A44C4138D8B1719978002B" name "DataTraveler 3.0" hash "9tkOQfor7joHOwNmZ7ojEufwi1S6xUt/BteFEZ0CCo8=" parent-hash "9JszuPWESBEur6P34acG7ZtBUqRa6fRgdsma6hSNpOk=" via-port "2-2" with-interface 08:06:50 with-connect-type "hotplug"
    [device] PolicyChanged: id=23
    target_old=block
    target_new=block
    device_rule=block id 0951:1666 serial "60A44C4138D8B1719978002B" name "DataTraveler 3.0" hash "9tkOQfor7joHOwNmZ7ojEufwi1S6xUt/BteFEZ0CCo8=" parent-hash "9JszuPWESBEur6P34acG7ZtBUqRa6fRgdsma6hSNpOk=" via-port "2-2" with-interface 08:06:50 with-connect-type "hotplug"
    rule_id=4294967294

La clef qui n'est pas connue dans les règles est bloquée.

## Règles avancées

### Via les USB subclass

La [doc qui va bien](https://www.usb.org/defined-class-codes) (cela reste tout de même assez bordélique)

*Comment repérer les classes et sous-classes d'un périphérique USB ?*

On installe usbutils et on liste les périphériques en mode verbeux. Mais tout d'abord, on répertorie les périphériques présents.

    # lsusb
    Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 008 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
    Bus 007 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
    Bus 006 Device 003: ID 046d:c534 Logitech, Inc. Unifying Receiver
    Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
    Bus 004 Device 002: ID 08ff:2810 AuthenTec, Inc. AES2810
    Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
    Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub

Je liste le périphérique qui m'intéresse, c'est-à-dire le dongle USB Logitech.

    # lsusb -v -d 046d:c534

    Bus 006 Device 003: ID 046d:c534 Logitech, Inc. Unifying Receiver
    Device Descriptor:ceux qui
    bLength                18
    bDescriptorType         1
    bcdUSB               2.00
    bDeviceClass            0
    bDeviceSubClass         0
    bDeviceProtocol         0
    bMaxPacketSize0         8
    idVendor           0x046d Logitech, Inc.
    idProduct          0xc534 Unifying Receiver
    bcdDevice           29.01
    iManufacturer           1 Logitech
    iProduct                2 USB Receiver
    iSerial                 0
    bNumConfigurations      1
    Configuration Descriptor:
        ...
        Interface Descriptor:
        ...
        bInterfaceClass         3 Human Interface Device
        bInterfaceSubClass      1 Boot Interface Subclass
        bInterfaceProtocol      1 Keyboard
        ...
        Interface Descriptor:
        ...
        bInterfaceClass         3 Human Interface Device
        bInterfaceSubClass      1 Boot Interface Subclass
        bInterfaceProtocol      2 Mouse
        ...

Le périphérique HID permet l'utilisation d'une souris et d'un clavier. C'est exactement ce que j'ai sous la main. :D

### Restriction pour un seul clavier USB

On va ajouter la règle présente sur le site d'USBGuard permettant de brancher un seul clavier USB.

    allow with-interface one-of { 03:00:01 03:01:01 } if !allowed-matches(with-interface one-of { 03:00:01 03:01:01 })

Qui se traduit en : « autorise un périphérique avec une interface de type `03:00:01` ou `03:01:01` s'il n'y a pas déjà un périphérique avec une interface de type `03:00:01` ou `03:01:01` présent et autorisé. »

On fait le test :

    # usbguard watch
    [IPC] Connected
    [device] PresenceChanged: id=22
    event=Insert
    target=block
    device_rule=block id 046d:c534 serial "" name "USB Receiver" hash "2Tmol95c6dv//0RiOpMlUD2f72+S/vuJuIfLIZ2rNXc=" parent-hash "bjtVSUusIDxj13VXcZojsuMRNykZ7U/PLmXWG7xPhDo=" via-port "6-2" with-interface { 03:01:01 03:01:02 } with-connect-type "hotplug"
    [device] PolicyChanged: id=22
    target_old=block
    target_new=allow
    device_rule=allow id 046d:c534 serial "" name "USB Receiver" hash "2Tmol95c6dv//0RiOpMlUD2f72+S/vuJuIfLIZ2rNXc=" parent-hash "bjtVSUusIDxj13VXcZojsuMRNykZ7U/PLmXWG7xPhDo=" via-port "6-2" with-interface { 03:01:01 03:01:02 } with-connect-type "hotplug"
    rule_id=12
    [device] PresenceChanged: id=23
    event=Insert
    target=block
    device_rule=block id 045e:00dd serial "" name "Comfort Curve Keyboard 2000" hash "LhioVURGmNOlKYkJ+KRUP3O8gdPkMUA5jE5N/6uiWRc=" parent-hash "7/Y7ayZhucdn9UUOSc/idMgOqIKmfZucV47nbxk0OLo=" via-port "3-1" with-interface { 03:01:01 03:00:00 } with-connect-type "hotplug"
    [device] PolicyChanged: id=23
    target_old=block
    target_new=block
    device_rule=block id 045e:00dd serial "" name "Comfort Curve Keyboard 2000" hash "LhioVURGmNOlKYkJ+KRUP3O8gdPkMUA5jE5N/6uiWRc=" parent-hash "7/Y7ayZhucdn9UUOSc/idMgOqIKmfZucV47nbxk0OLo=" via-port "3-1" with-interface { 03:01:01 03:00:00 } with-connect-type "hotplug"
    rule_id=4294967294

Le périphérique `046d:c534`, branché en premier, est autorisé alors que `045e:00dd` ne l'est pas.
