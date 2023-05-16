---
title: Mise à jour WSL2
description: Verrouillage des ports USB avec USBGuard
date: 2020-06-13
updated: 2023-02-23

taxonomies:
  tags:
    - linux
    - windows
---

WSL2 est distribué avec windows 10 version 2004, il fallait auparavant être insider pour pouvoir en profiter. Cette nouvelle version dispose d'un kernel linux et permet de faire fonctionner des machines virtuelles dans le sous-système Linux, plus besoin d'Hyper-V.

Afin de réaliser la migration, il faut avoir au préalablement installé la fonctionnalité "Plateforme d'ordinateur virtuel".

Dans une console Powershell avec les droits d'administrateur

    > Get-WindowsOptionalFeature -Online -FeatureName Vir*

    FeatureName      : VirtualMachinePlatform
    DisplayName      : Plateforme d'ordinateur virtuel
    Description      : Active la prise en charge de la plateforme d'ordinateur virtuel
    RestartRequired  : Possible
    State            : Disabled
    CustomProperties :

On va suivre la démarche de la [doc officielle de MS](https://docs.microsoft.com/fr-fr/windows/wsl/install-win10).

    > dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Outil Gestion et maintenance des images de déploiement
    Version : 10.0.19041.1
    Version de l’image : 10.0.19041.264
    Activation de la ou des fonctionnalités
    [==========================100.0%==========================]
    L’opération a réussi.

Et on redémarre. Notez l'utilisation du drapeau `norestart` dans la ligne de commande. :)

Désormais, nous allons pouvoir [mettre à jour le kernel Linux sous Windows](https://aka.ms/wsl2kernel).

![Mise à jour kernel Linux sous Windows](data/medias/maj-kernel-swl2.png)

Et maintenant, on met à jour la version de WSL utilisée par défaut.

    > wsl --set-default-version 2
    Pour plus d’informations sur les différences de clés avec WSL 2, visitez https://aka.ms/wsl2

Les distributions qu'on a déjà installées tournent sur WSL1, il faut donc les reconfigurer.

Il n'y a qu'une Ubuntu installée sur cette machine.

    > wsl --list --verbose
    NAME      STATE           VERSION
    * Ubuntu    Stopped         1

On la convertie en WSL2.

    > wsl --set-version ubuntu 2
    La conversion est en cours. Cette opération peut prendre quelques minutes...
    Pour plus d’informations sur les différences de clés avec WSL 2, visitez https://aka.ms/wsl2
    La conversion est terminée.

Cela semble OK, on vérifie.

    > wsl --list --verbose
    NAME      STATE           VERSION
    * Ubuntu    Stopped         2

La migration est réalisée. Reste à profiter du nouveau kernel Linux sous Windows. ;)
