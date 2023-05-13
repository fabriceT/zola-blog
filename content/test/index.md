---
title: "Test"
date: 2023-03-17
draft: true

extra:
  mermaid: true

---
# YARA

![Castex](castex.jpg)

## Gouvernement Macron
{% mermaiddiagram() %} 
---
title: Schéma des lois selon Macron
---
stateDiagram-v2
    s1: Opposition du peuple
    s2: Parlement d'accord
    s3: Allez vous faire foutre !
    
    state if_state <<choice>>
    state if_state2 <<choice>>
    [*] --> Loi

    Loi --> s2
    s2 --> if_state
    if_state --> s3: Non, alors 49.3
    if_state --> [*]: Oui

    Loi --> s1
    s1 --> if_state2
    if_state2 --> s3: Non, alors Mobile et BRAM-V
    if_state2 --> [*]: Oui

    s3 --> [*]

{% end %}

{% div(class="information") %}

blablabla
{% end %}

## TODO

[X] Créer des shortcodes pour créer des paragraphes de style information, warning...

[ ] Organiser les étiquettes et les catégories. C'est un peu le bordel ici.
