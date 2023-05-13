---
title: Jouons avec systemd-resolved
date: 2023-02-05

taxonomies:
  tags:
    - note
    - systemd
  categories:
    - système
    - réseau
---
Le service [systemd-resolved](https://wiki.archlinux.org/title/Systemd-resolved) est un serveur DNS local faisant office de cache DNS. [Sa page man](https://www.man7.org/linux/man-pages/man8/systemd-resolved.service.8.html).

Tout d'abord, il faut activer et lancer le service

    # systemctl enable --now systemd-resolved

Puis le fichier `/etc/resolv.conf` doit être remplacé par un lien symbolique vers le fichier généré par le service.

    # ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

On teste ensuite si tout est opérationnel

    $ resolvectl status
    Global
              Protocols: +LLMNR +mDNS -DNSOverTLS DNSSEC=no/unsupported
       resolv.conf mode: foreign
     Current DNS Server: 192.168.0.134
             DNS Servers 192.168.0.134
    Fallback DNS Servers 1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net 8.8.8.8#dns.google 2606:4700:4700::1111#cloudflare-dns.com 2620:fe::9#dns.quad9.net
                        2001:4860:4860::8888#dns.google

    Link 2 (eth0)
    Current Scopes: none
        Protocols: -DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported

    Link 3 (wlan0)
        Current Scopes: DNS LLMNR/IPv4 LLMNR/IPv6
             Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
    Current DNS Server: 192.168.0.134
           DNS Servers: 192.168.0.134

Comme on peut le voir, le serveur DNS utilisé pour la résolution des noms est mon serveur local (192.168.0.134).

## Requête

Le programme `resolvectl` permet réaliser des requêtes sur les DNS lors que le service systemd-resolved est en œeuvre.

Faisons une requête sur les enregistrements MX de Free.

    $ resolvectl query -t MX  free.fr
    free.fr IN MX 20 mx2.free.fr                                -- link: wlan0
    free.fr IN MX 10 mx1.free.fr                                -- link: wlan0

    -- Information acquired via protocol DNS in 117.5ms.
    -- Data is authenticated: no; Data was acquired via local or encrypted transport: no
    -- Data from: network

    $ resolvectl query -t MX  free.fr
    free.fr IN MX 10 mx1.free.fr                                -- link: wlan0
    free.fr IN MX 20 mx2.free.fr                                -- link: wlan0

    -- Information acquired via protocol DNS in 1.0ms.
    -- Data is authenticated: no; Data was acquired via local or encrypted transport: no
    -- Data from: cache

La requête a été réalisée par deux fois. Il est intéressant de voir que la source de la première est `network`, celle de la deuxième est `cache`, ce qui se voit sur le temps de réponse.

On peut également faire des recherches sur les entrées TXT

    $ resolvectl query -t TXT  free.fr
    free.fr IN TXT "google-site-verification=t11beEEtTGbjTRaHIR3ZAde9bcpIueH4i3Qn0orBExQ" -- link: wlan0
    free.fr IN TXT "v=spf1 include:_spf.free.fr ?all"           -- link: wlan0

Il est possible de lister les différents éléments à placer après l'option `-t` (type) ou `-c` (class) en y ajoutant `help`, par exemple `-t help`.

### À la dig 

Pour afficher requête comme avec dig, il faut ruser. Cela va nous permettre de voir quelques fonctionnalités de resolvctl.

On obtient le résultat suivant avec la commande dig

    $ dig @8.8.8.8 free.fr any +nocmd +noall +answer
    free.fr.		21255	IN	A	212.27.48.10
    free.fr.		21255	IN	NS	freens3-scw.free.fr.
    free.fr.		3255	IN	TXT	"v=spf1 include:_spf.free.fr ?all"
    free.fr.		21255	IN	AAAA	2a01:e0c:1::1
    free.fr.		21255	IN	MX	10 mx1.free.fr.
    free.fr.		21255	IN	TXT	"google-site-verification=t11beEEtTGbjTRaHIR3ZAde9bcpIueH4i3Qn0orBExQ"
    free.fr.		21255	IN	NS	freens2-g20.free.fr.
    free.fr.		21255	IN	SOA	freens1-g20.free.fr. hostmaster.proxad.net. 2023020801 10800 3600 604800 86400
    free.fr.		21255	IN	NS	freens1-g20.free.fr.
    free.fr.		21255	IN	MX	20 mx2.free.fr.

Détail amusant, on peut voir que je force l'utilisation d'un autre serveur DNS pour la requête, si on utilise le serveur DNS local (@IP 127.0.0.53), on obtient.

    dig free.fr any +nocmd +noall +answer
    free.fr.		24983	IN	AAAA	2a01:e0c:1::1
    free.fr.		24983	IN	MX	10 mx1.free.fr.
    free.fr.		24983	IN	MX	20 mx2.free.fr.
    free.fr.		24983	IN	NS	freens3-scw.free.fr.
    free.fr.		24983	IN	NS	freens1-g20.free.fr.
    free.fr.		24983	IN	NS	freens2-g20.free.fr.

Il n'y a pas le même degré de détail. :D

Si je devais utiliser la même requête avec resolvectl :

    $ resolvectl query -t ANY free.fr
    free.fr IN AAAA 2a01:e0c:1::1                               -- link: wlan0
    free.fr IN MX 10 mx1.free.fr                                -- link: wlan0
    free.fr IN MX 20 mx2.free.fr                                -- link: wlan0
    free.fr IN NS freens3-scw.free.fr                           -- link: wlan0
    free.fr IN NS freens1-g20.free.fr                           -- link: wlan0
    free.fr IN NS freens2-g20.free.fr                           -- link: wlan0

Sauf que ça ne fonctionne pas toujours. En effet, parfois seule l'entrée `A` apparait. Alors comment fait-on ? Je ne donnerai pas la réponse, car les résultats ont varié et je n'ai pas trouvé de réponse :(. Dig ne donnant pas forcément non plus les mêmes résultats en utilisant le serveur par défaut. Je suspecte des mises en cache en local et sur mon réseau (192.168.0.134 est aussi un cache DNS). Les DNS sont simples, cependant ça fini toujours en bordel couvré. 

On va voir comment avancer là-dedans en configurant un autre serveur DNS pour une interface réseau.

On configure le DNS 8.8.8.8 pour l'interface `wlan0`.

    # resolvectl dns wlan0 8.8.8.8

On peut également réaliser une requête sur une interface en particulier, ici `wlan0`.

    $ resolvectl query -t ANY free.fr -i wlan0

Bon, je préfère quand même dig même si ça peut dépatouiller pour des requêtes simples.

### Adresses supplémentaires

le service systemd-resolved ajoute, en plus de celles contenues dans `/etc/hosts`, quelques adresses amusantes :

- `_gateway` - l'adresse de la passerelle
- `_outbound` - l'adresse de l'interface réseau utilisée pour communiquer
- `localhost.localdomain` ou bien un nom suffixé par `.localhost` - adresses 127.0.0.1 et ::1