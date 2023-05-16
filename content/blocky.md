---
title: Filtrer les requêtes DNS avec Blocky
date: 2023-03-23

taxonomies:
  tags:
    - dns
  categories:
    - système
---

Certains utilisent [Pi-hole](https://pi-hole.net/) pour filtrer les requêtes DNS, d'autres utilisent [Blocky](https://0xerr0r.github.io/blocky/).

Bien que moins connu, Blocky dispose, entre autres, de fonctionnalités fort sympathiques :

* Filtrage des domaines selon les listes externes (liste noire et liste blanche)
* DNS sur TCP et UDP (IPv4 et IPv6), [DoH](https://fr.wikipedia.org/wiki/DNS_over_HTTPS), [DoT](https://fr.wikipedia.org/wiki/DNS_over_TLS).
* Export des métriques compatibles avec Prometheus
* Entrées DNS personnalisables
* Personnalisation des réponses DNS (surcharge d'un serveur, configuration par poste…)
* Mode CLI
* Mise en cache des résultats
* Log des requêtes dans une base de données
* Anonymisation des requêtes
* Un seul fichier de configuration et un seul exécutable

Dans ma configuration actuelle, la box du FAI est configurée pour retourner deux serveurs DNS aux clients demandant des baux DHCP : mon serveur DNS intermédiaire (un raspberry Pi) et le serveur Quad9. De cette manière, l'ensemble des appareils connectés au réseau se trouvent isolés de certaines nuisances pouvant provenir d'internet. La seule surprise a été un appareil électroménager qui a vu certaines de ses requêtes DNS bloquées par un filtre anti-pub, il a donc bénéficié d'un bail DHCP fixe et d'une configuration spéciale.

La configuration actuellement en prod

```yaml
upstream:
  default:
    - 9.9.9.9
    - 1.1.1.1
    - tcp-tls:cloudflare-dns.com:853
    - https://security.cloudflare-dns.com/dns-query
    - https://dns.digitale-gesellschaft.ch/dns-query

customDNS:
  customTTL: 1h
  rewrite:
    local: lan
  mapping:
    pi.lan: 192.168.0.134
    nas.lan: 192.168.0.200
    nas.kill-swit.ch: 192.168.0.200 # pas besoin de passer par internet pour accéder en local
    box.lan: 192.168.0.1

blocking:
  blackLists:
    ads:
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
      - https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
      - https://raw.githubusercontent.com/erkexzcx/disconnectme-pihole/master/services_Advertising.txt
      - https://raw.githubusercontent.com/erkexzcx/disconnectme-pihole/master/services_FingerprintingInvasive.txt
    trackers:
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts
      - https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
      - https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
      - https://justdomains.github.io/blocklists/lists/easyprivacy-justdomains.txt
      - https://raw.githubusercontent.com/erkexzcx/disconnectme-pihole/master/services_Analytics.txt
      - https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/windows
      - https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/samsung
      - https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/xiaomi
    malware:
      - https://raw.githubusercontent.com/erkexzcx/disconnectme-pihole/master/services_Cryptomining.txt
  whiteLists:
    xiaomi:
      - https://github.com/unknownFalleN/xiaomi-dns-blocklist/blob/master/xiaomi_dns_whitelist.lst
  clientGroupsBlock:
    default:
      - ads
      - trackers
      - malware
    # Appareil électroménager
    192.168.0.18/32:
      - malware

prometheus:
  enable: true
  path: /metrics

port: 53
httpPort: 4000
logLevel: warn
```

On peut voir les listes des filtres (noires et blanches) récupérés sur Internet. Elles s'appliquent à tous les appareils par défaut, sauf pour `192.168.0.18`, le fameux appareil ménager.

Les requêtes DNS sur `*.home` sont converties en `*.lan`. Un ping sur `pi.home` aura ainsi un retour de `pi.lan` situé à l'adresse `192.168.0.134`.

De même, le serveur intermédiaire intercepte les requêtes pour `nas.kill-swit.ch` et retourne son adresse IP sur le réseau local, ce qui évite de sortir sur Internet alors que le serveur est un voisin. Ainsi, pas de problème de certificats, tout est transparent qu'on soit sur le réseau local ou ailleurs.

Il y a encore pas mal de fonctionnalités que je n'ai pas exploitées.

## Utilisation de la ligne de commande

L'utilisation est simple : `--help` est votre ami.

Par exemple, pour réaliser des requêtes DNS avec Blocky :

```bash
$ blocky query box.lan
[2023-03-23 09:43:37]  INFO Query result for 'box.lan' (A):
[2023-03-23 09:43:37]  INFO 	reason:                  CUSTOM DNS
[2023-03-23 09:43:37]  INFO 	response type:            CUSTOMDNS
[2023-03-23 09:43:37]  INFO 	response:           A (192.168.0.1)
[2023-03-23 09:43:37]  INFO 	return code:                NOERROR

blocky query -t AAAA perdu.com
[2023-03-23 09:49:33]  INFO Query result for 'perdu.com' (AAAA):
[2023-03-23 09:49:33]  INFO 	reason:        RESOLVED (tcp+udp:9.9.9.9)
[2023-03-23 09:49:33]  INFO 	response type:             RESOLVED
[2023-03-23 09:49:33]  INFO 	response:      AAAA (2606:4700:3037::ac43:85b0), AAAA (2606:4700:3033::6815:5b2)
[2023-03-23 09:49:33]  INFO 	return code:                NOERROR
```

## Débogage

Il n'y a malheureusement pas la possibilité de simuler une requête en prétendant être à une autre adresse IP. Cela aurait été pratique pour me mettre à la place de mon appareil électroménager :smile:. Un filtre sur le journal `systemd` de Blocky a tout de même permis de voir le problème.

J'ai eu quelques surprises avec `systemd-resolved` lors de la configuration de Blocky. Il vaut mieux coupler l'utilisation d'un `dig @DNS-IP` et l'affichage d'un `resolvectl monitor` afin d'obtenir des informations exploitables pour un diagnostic. Cela m'a permis de voir que la configuration était correcte et que le problème venait d'une histoire de cache local sur la machine incapable de joindre un hôte.
