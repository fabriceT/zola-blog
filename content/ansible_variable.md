---
title: "Ansible : récupérer une variable à partir d'un fichier."
date: 2023-01-25

taxonomies:
  tags:
    - note
  categories:
    - ansible
    - système
---
Je devais récupérer le numéro de version d'un logiciel pas opensource à partir de son script d'installation disponible sur le web. Il n'y a pas, à ma connaissance d'autre source d'information. Le script d'installation ne me convient pas : il fait des trucs que je n'aime pas, comme fixer des droits trop laxistes, copier des fichiers de services systemd minimalistes et sans restriction sur les capacités du programme...

Lors de la mise à jour, je faisais un `grep` sur la sortie d'un `wget` pour récupérer la ligne contenant la version :

```bash
wget -qO- https://site.web/install.sh | grep "^VERSION"
```

La partie déploiement étant déjà gérée par `ansible`, il me fallait automatiser la chaîne complète.

Après plusieurs tests, je n'ai trouvé qu'une seule solution pour utiliser l'information venant du script :

- Récupérer le script,
- Utiliser la variable dans un bloc pour récupérer le binaire de la forme `app-{{ version }}`.

On arrive à ce résultat :
```yaml
- name: Get install script
    ansible.builtin.get_url:
        url: https://site.web/install.sh
        dest: /tmp/install.sh

- block:
    - name: Download file
        ansible.builtin.get_url:
            url: 'https://site.web/app-{{ app_version[0] }}'
            dest: '{{ app_bin_path }}/app'
            mode: '0755'
        notify: Restart service

    vars:
      app_version: "{{ lookup('file', '/tmp/install.sh') | regex_search('VERSION=\"(.*)\"', '\\1') }}"
```

Notez que la valeur de `app_version` est un tableau, il faut donc récupérer la première entrée du tableau.

Il y a probablement d'autres façons de faire. Cette solution me plait assez bien, car elle permet de mettre en évidence l'initialisation de la variable `app_version`.
