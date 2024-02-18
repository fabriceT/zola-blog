---
title: Spam qui déboulent me casse les cou..
date: 2023-06-05
draft: true


---

Les pourriels arrivent souvent par vagues : vous en recevrez plusieurs par jour, puis ce sera le calme plat durant une période plus ou moins courte. En ce qui me concerne, j'ai reçu durant plusieurs mois un mail quotidien concernant des ragots de célébrités. Puis plus rien, calme plat. Il n'y avait plus de mail à signaler à [la petite chouette](https://signalants.signal-spam.fr). Par la suite, mon petit mail quotidien est revenu, il s'agissait cette fois de gadgets comme des claquettes qui ne glissent pas ou un ventilateur de cou. Comme d'habitude, ce mail est écrit pour faire croire que j'ai volontairement consenti pour recevoir cette mer^W liste de diffusion.

## Commençons l'enquête

En déclarant ces nouveaux mails, je ne fus guère surpris de voir que le prestataire émetteur du mail ne m'était pas inconnu.Je me lance alors dans la recherche d'informations sur les précédents mails.

{% figure(alt="mail récent", url="chiffon.png") %}
Un mail récemment signalé
{% end %}

En regardant la partie désincription, on peut voir que la société SC2 Consulting est derrière la campagne de diffusion. On note l'information.

{% figure(alt="désinscription récent", url="mail-chiffon.png") %}
La partie désinscription du mail reçu
{% end %}

## Information sur la vague précédente

Maintenant, allons voir dans l'historique des signalements afin de voir si la vague de pourriels à un rapport avec la nouvelle.

{% figure(alt="", url="bricolo.png") %}
Avez-vous le bambou ?
{% end %}

{% figure(alt="", url="riz.png") %}
Qui veut du riz ?
{% end %}

{% figure(alt="", url="plomb.png") %}
Y a-t-il un électricien dans la salle ?
{% end %}

On remarque que le prestataire émetteur est le même. Reste à démontrer que l'initiateur de ces campagnes est le même.

Réalisons donc une recherche sur les noms de domaine :

a) mesobjetsdunet.fr

    domain:                        mesobjetsdunet.fr
    registrar:                     OVH
    Expiry Date:                   2023-10-31T13:49:47Z
    created:                       2019-10-31T13:49:47Z
    last-update:                   2022-11-30T23:15:01.807627Z
    nic-hdl:                       SC54732-FRNIC
    type:                          ORGANIZATION
    contact:                       SC2 Consulting
    address:                       SC2 Consulting
    address:                       90 rue Baudin
    address:                       92300 Levallois Perret
    country:                       FR

b) bricoulous.fr

    domain:                        bricoulous.fr
    registrar:                     OVH
    Expiry Date:                   2023-08-17T14:58:56Z
    created:                       2022-08-17T14:58:56Z
    last-update:                   2022-08-17T15:15:47Z
    nic-hdl:                       SC102937-FRNIC
    type:                          ORGANIZATION
    contact:                       SC2 Consulting
    address:                       SC2 Consulting
    address:                       90 rue Baudin
    address:                       92300 Levallois Perret
    country:                       FR

c) sortirauquotidien.com

    Domain Name: sortirauquotidien.com
    Registry Domain ID: 2681976577_DOMAIN_COM-VRSN
    Registrar WHOIS Server: whois.ovh.com
    Registrar URL: https://www.ovh.com
    Updated Date: 2023-03-01T06:57:16Z
    Creation Date: 2022-03-16T11:02:13Z
    Registrar Registration Expiration Date: 2024-03-16T11:02:13Z

d) linfoauquotidien.com

    Domain Name: linfoauquotidien.com
    Registry Domain ID: 2667238596_DOMAIN_COM-VRSN
    Registrar WHOIS Server: whois.ovh.com
    Registrar URL: https://www.ovh.com
    Updated Date: 2023-01-19T10:52:28Z
    Creation Date: 2022-01-10T16:00:16Z
    Registrar Registration Expiration Date: 2024-01-10T16:00:16Z

Les deux premiers appartiennent de toute évidence à la même société. Bien qu'il ne soit pas possible d'afficher les informations personnelles pour les deux derniers, On observe que le registar est le même.

## La nébuleuse YC

On va faire une recherche sur la société SC2 Consulting qui siège à NEUILLY-SUR-SEINE pour confirmer ce qui est encore un doute. La recherche permet de trouver une cartographie intéressante d'une ribambelle de sociétés qui gravitent autours d'un seul nom.

{% figure(alt="cartographie", url="cartographie.png") %}
<a href="https://www.pappers.fr/entreprise/sc2-consulting-509809646">Source</a>
{% end %}


On utilisera YC pour désigner la principale personne autours de ce montage puisque cela a été fait pour la société YC MEDIA. Allons voir si un site existe.

![site YC media](yc-media.png)

Il semble qu'on ait trouvé un lien entre ces deux vagues
