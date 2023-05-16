---
title: "Exécuter un script hébergé sur un serveur web"
date: 2023-03-20
draft: true

taxonomies:
tags:
- note
- chiffrement
- bash
categories:
- système
---

Nous allons voir ici comment exécuter automatiquement un script déposé sur un serveur web. L'idée m'est venue après avoir configuré un VPN sur un petit Raspberry Pi distant et avoir merdé sur la configuration du VPN (une petite virgule oubliée qui entraîner la coupure de la connexion). Il m'aurait été bien pratique de pouvoir modifier ce fichier de configuration en passant par un moyen détourné : un script posé sur un serveur qui serait récupéré et exécuté par le Pi.

J'ai les poils qui se hérissent à la pensée qu'un ordinateur pourrait exécuter automatiquement un script lambda posé sur le web, alors allons-y. On va tout de même tenter faire quelque chose à peu près biene.

Les besoins sont :

1. récupérer un fichier à un endroit précis
2. Ne pas exécuter le script s'il a déjà été exécuté (filtre par horodatage ou par empreinte)
3. avoir un moyen de vérifier que le script n'a pas été écrit par un malotru.

Pour le premier besoin, rien de plus simple : Il y a toujours `wget` ou `curl` qui traîne.

Pour le deuxième, ce sera par une empreinte puisque la mise en place d'une vérification de l'horodatage s’avère plus complexe pour un gain non significatif (faire une requête HTTP de type HEAD, puis extraire la date, la convertir et la comparer avec celle actuelle). On réalisera ainsi un simple `md5sum` sur le fichier récupéré et on comparera son empreinte avec celle sauvegardée dans un fichier marqueur.

Pour le troisième, nous utiliserons de la cryptographie. J'aurais aimé utiliser [kryptor](https://www.kryptor.co.uk/) ou [minisign](https://jedisct1.github.io/minisign/) pour la partie signature ou validation du script, mais le premier utiliser `dotnet` qui n'est pas présent pour le processeur armv7 de notre petite bête de somme et le second se fait descendre par OOM killer lors de la création de la clef privée. Ce sera donc [age](https://github.com/FiloSottile/age) qui sera utilisé pour la partie chiffrement. Pour rappel, les clefs cryptographiques `age` sont déjà utilisées par SOPS pour chiffrer des secrets. Je ne suis pas fan de l'incapacité de déterminer quelle clef a été utilisée lors du chiffrement, on aura peut-être une version avec GnuPG par la suite.

Passons à l’écriture du script.

```bash
#!/bin/env bash

SCRIPT_URL=http://my.webserv.er/script
TEMP=$(mktemp)
LAST_RUN=/tmp/last.run
SCRIPT_DST=/tmp/my_script.sh
AGE_KEY="${HOME}/age-keys.txt"

function check_lastrun() {
    MD5SUM=$(md5sum "${TEMP}" | cut -d' ' -f1)

    if [ ! -f "${LAST_RUN}" ]; then
        echo "${LAST_RUN} n'existe pas"
        return 0
    fi

    LAST_MD5=$(cat ${LAST_RUN})
    if [ "${MD5SUM}" = "${LAST_MD5}" ]; then
        echo "Script déja executé"
        return 1
    fi

    return 0
}

rm "${SCRIPT_DST}"

if ! wget -q "${SCRIPT_URL}" -O "${TEMP}"; then
    echo "Rien à récupérer"
    exit 1
fi

if check_lastrun; then
    age -d -i "${AGE_KEY}" "${TEMP}" > "${SCRIPT_DST}"
    if [ "$?" -eq "0" ]; then
        echo "=== Execution ==="
        bash "${SCRIPT_DST}"
        echo "${MD5SUM}" > "${LAST_RUN}"
    fi
fi

rm "${TEMP}" "${SCRIPT_DST}" 2>/dev/null
```

La fonction `check_lastrun` du script ci-dessus retourne 0 si le fichier `${LAST_RUN}` n'existe pas ou si l'empreinte MD5 du script et différente de celle enregistrée dans le fichier lors d'une précédente exécution. Il y a probablement d'autres vérifications à faire sur ce point. Le reste du script est, à mon avis, lisible et compréhensible.

Maintenant que nous avons un script prêt, regardons comment utiliser tout cela.

Créons les clefs `age` pour l'ordinateur devant exécuter le script

```bash
$ age-keygen -o age-keys.txt
Public key: age18gk6f4k02quuk3jnejfc54a526zkf5mjv8mh20y2eyyax9m3ufjqjku5ew
```

Écrivons les instructions à exécuter, puis chiffrons-les en utilisant la clef publique `age18gk6f4k02quuk3jnejfc54a526zkf5mjv8mh20y2eyyax9m3ufjqjku5ew`.

```bash
$ age -r age18gk6f4k02quuk3jnejfc54a526zkf5mjv8mh20y2eyyax9m3ufjqjku5ew -a script.sh > encoded-script
$ cat encoded-script
-----BEGIN AGE ENCRYPTED FILE-----
YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBmMkQwbzNlS0tFV2U2dHRq
VDhsNW1KRStTcVg3akRkemV6TWdubjYxRjJjCkZTdiszeHRFT2NQMmJyQnJPOW5B
MHBJeDBQMloxUk5vQm9xL0hjUFliTVUKLS0tIHR5WlJ6RHo5ZlRtT0M1NzBNYlZL
K3FUNzBWNlZxVjgwcUhiSXN1eXA5S0EKNuyHvzxRxty4YR55M8smVqTan2+hf2Xi
/6vVqg34C8+cN8GgR5m/cMZeHfJNE9pW7YZ8OVMFQ3JQtZm9MdnOh96xbbg=
-----END AGE ENCRYPTED FILE-----
```

On utilise ici l'option `-a` pour créer un fichier encodé en ASCII. Reste désormais à pousser le fichier sur son emplacement final `$SCRIPT_URL`.

La partie chiffrée est située entre les balises `BEGIN` et `END`. Vu qu'on utilise l'empreinte MD5 pour conditionner l'exécution du script, il est possible d'ajouter des lignes après `END` pour relancer le script sans en modifier le contenu.
