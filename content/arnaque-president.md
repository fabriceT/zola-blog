---
title: L'arnaque au faux président est une comédie tragique
date: 2023-03-06
updated: 2023-03-08
draft: true

taxonomies:
  tags:
    - sécurité
  categories:
    - divers
---

Loin de moi l'idée de me moquer de ceux qui ont été les victimes des arnaques dites du faux président, le type d'arnaque dans laquelle une personne se fait passer pour un haut responsable, de la société ou non, et demande à ce que des fonds soient virés en toute discrétion. Le cas de l'[arnaque au faux Le Drian a été un révélateur à 38 millions d'euros](https://www.francetvinfo.fr/france/ile-de-france/paris/arnaque-au-faux-president-38-millions-d-euros-escroques_5664851.html). Ces arnaques sont avant tout le fruit d'une chaîne d'évènements, de décisions désastreuses et des conséquences en découlant.

Quelle est la principale raison conduisant une personne A (qu'on prénommera Alice) à réaliser une opération pour le compte d'une personne B (lui, c'est Bob) alors que Bob est incarné par une personne C (Cliff, qui croit un Cliff ?) ? La raison est simple : l'échec de la validation de l'identité de Bob. Il y a beaucoup de raison pour que cette validation échoue, peut-être même parce qu'il n'y a tout simplement [pas eu de validation](https://fr.wikipedia.org/wiki/Rasoir_de_Hanlon).

L'arnaque au faux président, c'est principalement ça :

> Bonjour Alice,
>
> J'ai un besoin URGENT d'avoir 2 millions d'euros versés sur le compte XXX-XXXX pour l'anniversaire du stagiaire.
>
> Je compte lui faire une surprise demain. Surtout, tu n'en parles à personne. Je compte sur toi.
>
> Je ne suis pas joignable par téléphone, il est tombé dans les toilettes.
>
> Bisous, Bob.

Cliff pourrait mettre un peu plus le fond et de forme pour enfariner Alice. Cela suffira à saisir l'idée.

Nous allons voir qu'il est possible d'éviter ce genre d'arnaque avec de la formation et de la sensibilisation. Avant de continuer, sachez que je ne suis pas un expert en arnaque, sécurité, arnaque ou botanique. Je ne suis qu'une personne sensibilisée au problème de la sécurité informatique. Ce sera donc à travers ces yeux que je décris la situation telle que je la ressens.

Le problème de validation de l'identité d'une personne et, par extension, l'identification de l’origine de la source d’un message est un problème très ancien. On a inventé les sceaux, la signature, les mots de passes… pour tenter de résoudre ce problème. Cependant, chaque solution comporte des faiblesses pouvant être exploitées par des personnes plus ou moins motivées à usurper une identité ou falsifier une source.

La première solution, la plus rudimentaire et la plus fiable est l'authentification de proximité : la personne est physiquement en face de nous et on compare avec les informations dont on dispose sur elle. Le seul moyen de contourner cette validation était de trouver un sosie convenable, suffisamment bon acteur et imitateur pour interpréter correctement l'individu à personnifier. Le contournement de ce type d’authentification peut s'avérer être difficile selon la proximité des intervenants.

Le principal problème de ce type d’authentification est qu’on ne peut pas toujours avoir la personne en face de soi. On utilisait alors des mesures destinées à identifier la source : signature, adresse, écriture… Puis la technologie est venue pour s'interfacer dans ce type d'échanges, apportant des différences majeures tout en donnant l'impression que rien avait changé.

L'arnaque de type faux « le Drian » reposait sur le fait que le contact visuel et audio était réalisé à distance avec une connexion de mauvaise qualité afin qu'Alice se persuade que pixel Bob était le fruit de la qualité de la transmission. Cliff utilisait cette ruse pour atténuer les défauts de son postiche. Il fallait également qu’Alice ne puisse pas remettre en question la situation. Pour cela, Cliff était rusé et avait du bagou.

Vous pouvez dire qu'Alice n'était pas dans un bon jour et qu'elle aurait dû flairer le piège, qu'une bonne transmission pour une visioconférence aurait permis une authentification de proximité. Détrompez-vous, inconscients que vous êtes ! Le [deepfake permet d'imiter l'apparence visuelle d'une personne à travers le prisme des technologies](https://www.youtube.com/watch?v=wq-kmFCrF5Q).

Il ne faut pas forcément faire confiance à une personne parce qu'on la voit où l'entend, car votre perception de l’information passe par des technologies qui peuvent altérer ce que vous voyez ou entendez.

## Retour vers le passé.

La sécurité des communications a concerné les militaires depuis bien longtemps. À l’époque de Jules César, les militaires romains utilisaient un chiffrement par décalage de lettre pour rendre les messages illisibles, à l'époque.

Un tournant dans la communication sécurisée a été franchi après la seconde guerre mondiale suite au cassage du code [d'Enigma](https://fr.wikipedia.org/wiki/Enigma_(machine)), une solution cryptographique allemande de la seconde guerre mondiale. Elle devait permettre aux Allemands de se coordonner sans « divulgacher » de détails sur leurs plans puisque l'information étant protégée par un moyen cryptographique.

Dans le domaine de la cybersécurité, l'information est qualifiée en 4 points :

1. sa confidentialité
2. son intégrité
3. sa disponibilité
4. la non-répudiation

Enigma permettait de s'assurer que l'information était :

- confidentielle, car il fallait la clef pour lire l'information
- était intègre, parce qu'il fallait la clef pour modifier l'information

Sa disponibilité n'était pas importante, il s'agissait ici de la responsabilité de la chaîne de commandement.

Quant à sa non-répudiation, n'importe quel opérateur ayant accès à un outil de chiffrement et à la clef en usage pouvait envoyer sa liste de courses comme ordre de manœuvre. Il était encore de la responsabilité de la chaîne de commandement de s'assurer que les messages sortants avaient une origine correcte.

On était en présence d'un circuit dans lequel les informations étaient protégées et, reposant en partie sur cette protection, les sources étaient validées.

Puis, par ignorance, méconnaissance ou toute autre raison (du genre « on a rien à craindre », « on est les meilleurs », « trop compliqué de suivre les recommandations, on va faire comme on a toujours fait »… choisissez), des erreurs ont été commises dans l'utilisation de l'outil, ce qui a laissé la possibilité d’exploiter des failles. La protection ayant été cassée. Ce qui était à l'origine un échange sécurisé s’est transformé en un échange de cartes postales. Quant aux Allemands, ils avaient la certitude que personne d’autre ne pouvait lire ce qui était écrit sur leurs cartes postales.

Méfiez-vous de la technologie, car elle peut être mal utilisée ou ne pas être fiable.

## Fin du flash arrière

Maintenant que le lien entre l'arnaque au faux président et Enigma commence à se dessiner plus clairement dans votre esprit, on va entrer davantage dans le côté technique.

Enigma était une solution cryptographique symétrique : il n'y a une seule clef pour chiffrer et déchiffrer. N'importe qui possédant la clef peut générer un message chiffré. C'est un système dans lequel la diffusion de la clef doit être restreinte : trop de personne ayant la clef peut entrainer sa fuite. Il est donc usage de changer régulièrement de clef pour limiter sa fuite. Un problème survient lorsqu'on a chiffré une archive : quelle était la clef en usage à ce moment-là ?

L'avancée de la technologique et des capacités de traitement mathématique a permis la création de la cryptographie asymétrique où chaque participant à un échange d'information possède sa propre clef. Les systèmes de cryptographie asymétrique peuvent permettre de garantir l’origine de la transmission, restant à la charge des interlocuteurs à valider que le possesseur de la clef est bien celui qui il prétend être.

Pour être plus précis sur le fonctionnement du système de chiffrement asymétrique, un participant possède en réalité deux clefs :

- Une clef privée permettant le chiffrement ou la signature. Cette clef ne doit jamais être diffusée, ni accessible à un tiers.
- Une clef publique, dérivée de la clef privée, permettent de chiffrer un message à l’attention du participant en étant sûr qu’il puisse déchiffrer ce message.

## Sécuriser ses canaux de communications

Nous venons de voir qu’il existe des moyens pour s’assurer de la confidentialité des données et de la validation de la source. Reste à mettre en place des mesures permettant de l’utiliser. Pas de recette toute faite ici, cela dépend de ce que vous utilisez.

La sécurité de ses communications est garantie par les faits suivants :

- Les intervenants comprennent les enjeux et les niveaux de confidentialité,
- ils savent utiliser les canaux de communications sécurisés selon les exigences en place,
- ils savent identifier un intervenant en ayant toutes les garanties raisonnables qu'il s'agit bien de lui,
- ils savent comment maintenir la sécurité au niveau demandé.

### Confidentialité

Tout d'abord, ayez conscience que nous diffusons suffisamment d'information pour qu'un tiers puisse essayer de se faire passer pour nous. Il est donc important de limiter cette diffusion d'information ou de restreindre son accès.

L'information peut être également diffusée de manière induite. Il suffit de traîner sur des réseaux sociaux pour découvrir des schémas de communication. C'est d'autant plus vrai sur les réseaux sociaux professionnels où l'on pourra se délecter de ces schémas qu'on pourra facilement qualifier de `corporate bullshit` : Je pourrais être consultant RH en quelques smileys.

Il faut chiffrer tout support pouvant être perdus, volés ou être déplacés. Tout document confidentiel doit être par ailleurs chiffré ou inaccessible au quidam. De même, le système utilisé pour le chiffrement doit bénéficier d'une attention toute particulière.

Les mails sont par défaut des cartes postales. Le petit cadenas garantit uniquement que la transmission est chiffrée, pas de qui la chiffre, ni qu'ils ne seront pas plus tard visibles par des tiers. Les seuls mails confidentiels sont ceux chiffrés, par [GnuGP](https://gnupg.org/) par exemple.

Règle numéro 1 : ce qui est diffusé sur le web est ou deviendra publique, même si vous en limitez l'accès.

### Intégrité

Les méthodes de chiffrement modernes permettent de garantir l'intégrité des informations. Ainsi, toute altération d'une information chiffrée ou signée est détectable.

### Disponibilité

C'est aux personnes en charge de l'IT de s'assurer que l'information sera toujours disponible et de mettre en places de processus permettant de garantir aucune perte d'information. Notez qu'il faut donner à ces personnes des moyens de réaliser leurs missions. Même si vous pensez que les potions de mana lootées dans un MMRPG ne sont pas suffisantes.

De même, il en est de la responsabilité des utilisateurs finaux de s'assurer qu'ils respectent bien les recommandations.

### La non-répudiation

La cryptographie asymétrique permet, si la clef privée est protégée, doit garantir que l'expéditeur est bien à l'origine de l'information et qu'il n'y a pas eu d'altération.

Certaines solutions de chiffrement asymétrique n'offrent malheureusement pas la possibilité de vérifier qui a chiffré : [age](https://github.com/FiloSottile/age) par exemple. Alors que d'autre le font : [kryptor](https://www.kryptor.co.uk/)

L'usage de solutions de non-répudiation est généralement compliquée à mettre en place, les interlocuteurs pouvant se sentir frileux à l'idée de ne pas pouvoir nier ou revenir sur les informations qu'ils ont données. Le cas classique est l'envoi de mail sur un détail, sensible ou non, suivi d’une réponse par téléphone parce que « c'est plus simple de répondre ainsi ». En fait, il s'agit surtout de ne pas laisser de traces pouvant être compromettantes sur la réponse apportée à ce moment-là. La réponse donnée a posteriori pouvant être ajustée selon les résultats.

Imaginez qu'il est parfois compliqué d'avoir une trace écrite alors, imaginez qu'il devienne impossible de répondre : « ce n'est pas moi, on m'a piraté mon compte ».

## Comment faire si on est en dehors d'un système permettant l'utilisation de la cryptographie

Il faut s'assurer de la nature de l'interlocuteur et de l'information.

Astuce à l'usage de l'encadrement agacé : Si tu as l'impression que ton subalterne t'emmerde en te posant des questions et met en doute tes informations ainsi que ta nature parce que tu es dans une situation où tu n'es pas capable de garantir qui tu es. C'est toi qui fais de la merde, pas lui. Sois content d'avoir des subalternes consciencieux.

## Conclusion

Comme dit l'adage qu'on sort toujours dans ces cas-là : une chaîne est aussi solide que son maillon le plus faible. Il faut sensibiliser, éduquer et former.

Vous n'avez pas idée de ce qu'on peut voir parce que l'informatique, c'est : « trop coûteux », « on a toujours fait comme ça », une charge, trop compliqué, « pas mon problème », « le gars là-bas qui s'occupe de tout »… Si j'avais dû me cogner le front avec ma main quand une décision était uniquement justifiée par un des arguments cités ci-dessus, je me serais lancé dans une activité professionnelle plus reposante, comme celle d'attaques nocturnes de distributeurs de billets en les ouvrant à l'aide de mon os frontal, suite à l’importante augmentation de sa densité osseuse.
