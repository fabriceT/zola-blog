---
title: Certificats SSH pour les hôtes
date: 2023-04-03
taxonomies:
  tags:
    - SSH
    - note
  categories:
    - Sécurité
---

Les certificats SSH sont un moyen d'authentifier les utilisateurs et les hôtes.
Nous allons voir ici comment authentifier des hôtes (ordinateurs) afin de garantir
leur authenticité et d'éviter, à la première connexion, le message demandant de
confirmer qu'il s'agit bien du bon serveur.

Cela requiert de mettre en place une autorité de certification. Il est recommandé
d'avoir une autorité de certification distincte pour les hôtes et les utilisateurs.

## Création d'une autorité de certifications

On crée les clefs nécessaires pour constituer l'autorité de certification :

* La clef privée va permettre de générer un certificat signant les clefs publiques
SSH des serveurs.
* La clef publique va être utilisée par les clients pour s'assurer de la validité
des certificats des serveurs.

```bash
ssh-keygen -a 256 -f ssh_server_ca -t ecdsa -C "CA Server"
```

Ce trousseau de clefs doit être correctement protégé : On veut signer nos clefs 
pas que des autres signent les leurs et les intègrent dans notre infra.

## Création du certificat SSH

Le certificat permet de garantir l'authenticité de l'hôte. Il est le résultat de
la signature de la clef publique du serveur par la clef privée de l'autorité de
certification.

On génère donc un certificat avec la clef publique `ssh_host_ed25519_key` de
l'hôte `arsinoe.home` ainsi :

```bash
ssh-keygen -I CA_SERVER -s ssh_server_ca -h -n arsinoe.home -V +12w /etc/ssh/ssh_host_ed25519_key.pub
```

Explication :

* `-I` L'identifiant du certificat, ici `CA_SERVER`.
* `-s` Définit le CA qui va être utilisée pour la signature.
* `-h` Un certificat d'hôte va être généré.
* `-n` Nom utilisé pour le certificat. Il peut y en avoir plusieurs séparés par
une virgule.
* `-V` Intervalle de validité du certificat généré, ici 12 semaines.

Le certificat délivré sera nommé `ssh_host_ed25519_key-cert.pub`.

## Utilisation du certificat

### Sur l'hôte

Le certificat utilisé pour l'authentification du serveur doit être précisé dans
le fichier `/etc/sshd_config` en y ajoutant la ligne suivante :

```
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

On redémarre le service SSH avec `systemctl reload sshd` afin que l'hôte présente
son certificat aux clients SSH.

### Chez les clients

Le contenu de la clef publique du certificat (le contenu de `server_ca.pub`) doit
être indiqué dans le fichier `/etc/ssh/ssh_known_hosts`.

```
@cert-authority *.home ecdsa-sha2-nistp256 AAAAE2VjZHNhL[…]oPQL9oioSHOyBjrN6gB0=
```

Cela va permettre au client de s'assurer que les certificats des hôtes dont le
nom correspond au motif suivant `*.home` ont bien été signés par l'autorité de
certification.

## Information sur les clefs et certificats

Il est possible d'afficher les informations des clefs et des certificats

1) clef publique du CA

```bash
ssh-keygen -lf server_ca.pub
256 SHA256:6EGddkLwX2eS2H1UI1jyHYRxK4CsgrSZJ8uyC/IfbbA (ECDSA)
```

2) Clef publique du serveur

```bash
# ssh-keygen -lf ../ssh_host_ed25519_key.pub
256 SHA256:P8+P3NKsGxfR4oRyF0eb7r30SNGmpDk/InpRxaetpSA (ED25519)
```

2) Certificat serveur

```bash
# ssh-keygen -Lf ../ssh_host_ed25519_key-cert.pub
../ssh_host_ed25519_key-cert.pub:
	Type: ssh-ed25519-cert-v01@openssh.com host certificate
	Public key: ED25519-CERT SHA256:P8+P3NKsGxfR4oRyF0eb7r30SNGmpDk/InpRxaetpSA
	Signing CA: ECDSA SHA256:6EGddkLwX2eS2H1UI1jyHYRxK4CsgrSZJ8uyC/IfbbA (using ecdsa-sha2-nistp256)
	Key ID: "CA_SERVER"
	Serial: 0
	Valid: from 2023-04-03T14:31:00 to 2023-06-26T14:32:51
	Principals: 
		arsinoe.home
	Critical Options: (none)
	Extensions: (none)
```

## Regardons une connexion SSH

On va réaliser une connexion SSH en mode verbeux sur un autre hôte configuré pour
utiliser un certificat SSH, ici `alarmpi.home` : 

```bash
$ ssh -vvv alarmpi.home

debug1: Reading configuration data /etc/ssh/ssh_config
debug3: expanded UserKnownHostsFile '~/.ssh/known_hosts' -> '/root/.ssh/known_hosts'
debug3: expanded UserKnownHostsFile '~/.ssh/known_hosts2' -> '/root/.ssh/known_hosts2'
debug2: resolving "alarmpi.home" port 22
debug3: resolve_host: lookup alarmpi.home:22
debug3: ssh_connect_direct: entering
…
debug3: record_hostkey: found ca key type ECDSA in file /etc/ssh/ssh_known_hosts:2
debug3: load_hostkeys_file: loaded 1 keys from alarmpi.home
…
debug1: Server host certificate: ssh-ed25519-cert-v01@openssh.com SHA256:7ifMatYuCGqfNE9ON9m+cy6yoVgZUYsBFg3VGPdUHPw, serial 0 ID "ALARMPI" CA ecdsa-sha2-nistp256 SHA256:6EGddkLwX2eS2H1UI1jyHYRxK4CsgrSZJ8uyC/IfbbA valid from 2023-04-03T16:02:00 to 2023-06-26T16:03:36
debug2: Server host certificate hostname: alarmpi.home
…
```

On peut voir l'étape où SSH trouve la clef publique du certificat et celle où il
récupère le certificat de l'hôte

Il est possible de voir avec `ssh-keyscan` que les clefs utilisées pour
l'authentification ne sont pas changées avant et après la création du certificat.
Le certificat est uniquement là pour indiquer que la clef présentée par le serveur
est considérée comme fiable.

Le même programme peut être utilisé pour afficher le certificat :

```bash
$ ssh-keyscan -c alarmpi.home
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5L[…]6Ec5qRxW9oM1
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
```

ou en chaînant les instructions 

```bash
ssh-keyscan -c alarmpi.home | ssh-keygen -Lf -
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
# alarmpi.home:22 SSH-2.0-OpenSSH_9.3
(stdin):1:
        Type: ssh-ed25519-cert-v01@openssh.com host certificate
        Public key: ED25519-CERT SHA256:7ifMatYuCGqfNE9ON9m+cy6yoVgZUYsBFg3VGPdUHPw
        Signing CA: ECDSA SHA256:6EGddkLwX2eS2H1UI1jyHYRxK4CsgrSZJ8uyC/IfbbA (using ecdsa-sha2-nistp256)
        Key ID: "ALARMPI"
        Serial: 0
        Valid: from 2023-04-03T16:02:00 to 2023-06-26T16:03:36
        Principals: 
                alarmpi.home
        Critical Options: (none)
        Extensions: (none)

```
