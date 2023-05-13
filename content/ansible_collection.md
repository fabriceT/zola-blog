---
title: "Ansible : utilisation des collections"
date: 2023-02-21
updated: 2023-02-21

taxonomies:
  tags:
    - note
  categories:
    - ansible
    - système
---
On crée une collection

```bash
$ ansible-galaxy collection init step.test
```

On va dans le répertoire

```bash
$ cd step/test/roles
$ ansible-galaxy role init premierrole
```

On ajoute une tâche dans le rôle nouvellement créé

```yaml
- name: Debug test
  debug: msg="Mon premier role"
```

On crée une archive de la collection

```bash
$ ansible-galaxy collection build
Created collection for step.test at /home/phab/.ansible/step/test/step-test-1.0.0.tar.gz
```

On installe la collection

```bash
$ ansible-galaxy collection install step/test/step-test-1.0.0.tar.gz -p collections
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'step.test:1.0.0' to '/home/phab/.ansible/collections/ansible_collections/step/test'
step.test:1.0.0 was installed successfully
```

On crée un playbook utilisant la collection

```yaml
- hosts: localhost
    gather_facts: false
    tasks:
    - import_role:
        name: step.test.premierrole
```

ou encore

```yaml
- hosts: localhost
    gather_facts: false

    collections:
      - step.test

    tasks:
      - import_role:
          name: premierrole
```

On lance le test

```bash
$ ansible-playbook -c local test.yml

PLAY [localhost] *********************************************************************************************************************************************

TASK [step.test.premierrole : Debug test.] *******************************************************************************************************************
ok: [localhost] => {
    "msg": "Mon premier role"
}

PLAY RECAP ***************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
