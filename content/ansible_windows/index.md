---
title: "Ansible : Déploiement sur Windows"
date: 2020-10-16

taxonomies:
  tags:
    - windows
  categories:
    - ansible
    - système
---
Ansible est un outil d'automatisation et de configuration que j'apprécie beaucoup. Comme la gestion des postes et serveurs sous Windows est d'une hérésie complète, Ansible offre une possibilité supplémentaire de configurer des ordinateurs par lots.

Note: je n'ai pas utilisé Ansible pour des postes Windows en production, j'utilisais DSC et des scripts Powershell pour automatiser l'ensemble.

## Configuration du client Windows

Puisque la prise en charge de SSH est considérée comme expérimentale sous Windows, nous allons configurer le poste pour qu'il accepte les connexions WinRM. La doc Ansible est bien détaillée ([Configuration WinRM](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#winrm-setup)).

```powershell
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:tempConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file
```

Nous allons utiliser un compte administrateur local pour la connexion, car je n'ai pas de contrôleur de domaine et pas l'envie d'en avoir un pour une poignée de postes rarement utilisés.

## configuration Ansible

On va mettre en place une configuration pour que des programmes spécifiques soient installés sur les machines Windows.

Faisons ça dans l'ordre.

### Fichiers hosts

On définit un groupe de machines windows avec des noms explicites. Puis, on modifie le comportement d'Ansible en surchargeant certaines variables Ansible. Le mot de passe peut être saisi lors de l'exécution du playbook, pas obligé de l'ajouter à la configuration Ansible.

On se fiche de la validation du certificat, je n'ai pas d'infrastructure pour gérer les certificats.

```ini
[win]
x220 ansible_host=192.168.0.41
x220i ansible_host=192.168.0.44

[win:vars]
ansible_connection=winrm
ansible_user=Administrateur
ansible_password=CorrectHorseBatteryStapple
ansible_winrm_server_cert_validation=ignore
```

### Configuration des nœuds

Les machines x220 et x220i, des postes clients, n'ont pas le même rôle et n'ont pas besoin de la même configuration. On va utiliser les répertoires vars permettant de configurer les variables pour un groupe donné (`group_vars`) et pour un nœud donné (`host_vars`).


Pour `group_vars`, on crée dans le répertoire un fichier `win.yml` ("nom du groupe".yml).

```yaml
packages_std:
  - 7zip
  - ConEmu
  - keepassxc
  - powertoys
  - sumatrapdf
  - syncthing
  - sysinternals

packages_dev:
  - git.install
  - golang
  - mRemoteNG
  - powertoys
  - vscode.install

# Installation du groupe package dev ?
devel_group: false
```

On trouve deux groupes de paquets chocolatey : un standard et l'autre de développement. Par défaut, on ne veut pas que le groupe de paquets de développement soit installé.

Pour `host_var`, on va créer un fichier `x220.yml` ("nom du nœud".yml). Comme le groupe de paquets de développement est par défaut non installé, on va surcharger cette configuration.

```yaml
devel_group: true
```

C'est tout. Pas besoin d'un fichier x220i.yml pour ce niveau.

### Le playbook.

On a deux machines et la configuration. Reste le passage à l'acte.

Notre playbook

```yaml
---
- hosts: win
  gather_facts: no
  tasks:
  - name: Install default packages
    win_chocolatey:
      name: "{{ packages_std }}"
      state: present

  - name: Install dev packages
    win_chocolatey:
      name: "{{ packages_dev }}"
      state: present
    when: devel_group == true
```

On y va

```bash
$ ansible-playbook win.yml

PLAY [win] *********************************************************************************************************************************************************************

TASK [Install default packages] ************************************************************************************************************************************************
changed: [x220]
changed: [x220i]

TASK [Install dev packages] ****************************************************************************************************************************************************
skipping: [x220i]
changed: [x220]

PLAY RECAP *********************************************************************************************************************************************************************
x220                       : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
x220i                      : ok=1    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Voilà, Ansible a installé le paquet standard sur les deux machines et ignoré x220i pour le paquet développement.

L'installation est réalisée à l'aide de [chocolatey](https://chocolatey.org/). Si celui-ci n'est pas installé, il va être automatiquement installé avant de procéder à l'action.

## Vidéo du déploiement en action

{{ video(alt="installation", url="deploiement-ansible-win.webm") }}
---

* Sources des [modules chocolatey](https://github.com/chocolatey/chocolatey-ansible)
* Sources des [modules Windows](https://github.com/ansible-collections/ansible.windows)