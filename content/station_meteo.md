---
title: Station météo (ESP-12) et Prometheus
date: 2021-04-27

taxonomies:
  tags:
    - esp8266
  categories:
    - supervision
    - électronique
---

Après avoir acheté un appareil connecté bon marché, je me suis rendu compte qu'il contenait un ESP8266. Voulant m'amuser avec, j'ai sorti un peu d'électronique des cartons pour m'amuser avec la lampe. En fait, je n'ai jamais touché la lampe et me suis amusé sur ma carte d'expérimentation ESP-12. 

En recherchant une mise à jour du firmware, je suis tombé sur [ESP Easy](https://espeasy.readthedocs.io/en/latest/) qui permet de faire facilement de l'IOT. Le projet s'est donc orienté en fonction de ce que j'avais sous la main : des capteurs environnementaux. Vive la future station météo complète connectée en Wifi.

Matériel utilisé :

* ESP8266 (ESP-12) ;
* capteur BMP280 (Température, Hygrométrie, Pression atmosphérique) ;
* capteur BH1750 (Luminosité) ;
* un firmware ESP Easy.

Comme une instance Prometheus tourne sur mon infra, l'ESP sera utilisé pour monitorer les conditions météorologiques. Reste à déterminer quelles seront les alertes que l'on peut sortir.

## Montage électronique

Pour la partie électronique, rien de compliqué : les capteurs communiquent en I2C. ESP easy s'occupe de tout. Il m'a juste fallu calibrer le capteur (définir l'offset permettant d'obtenir la température réelle).

Donc dans l'ordre :

* flashage de l'ESP avec l'outil d'ESP Easy ;
* Alimentation en 3,3V pour les deux capteurs ;
* Raccordement des SDA et SCL (respectivement D2 et D1 sur l'ESP-12) ;
* Mettre l'ESP à côté d'un thermomètre pour mesurer la diférence de température.

Vu la simplicité du montage, les problèmes que l'on peut rencontrer sont principalement de l'ordre de la connectique (fichus faux contacts !).

## Ajout à la supervision

### Configuration de l'exporter

ESP Easy met à disposition un fichier JSON avec tout un tas de valeurs (adresse du type http://<ip-node>/json), on utilisera l'exporter Prometheus : [json_exporter](https://github.com/prometheus-community/json_exporter) pour récupérer les valeurs qui nous intéressent.

Fichier de configuration de l'exporter

```yaml
  metrics:
  - name: nodemcu_load
    path: "{ $.System.Load }"
    help: CPU Load for the node

  - name: nodemcu_sensor
    type: object
    path: "{ $.Sensors.*.TaskValues.* }"
    labels:
      name: "{ .Name }"
    values:
      value: "{ .Value }"
```

Ce qui donne sur l'adresse `http://<node_exporter>:7979?probe?target=http://<ip-node>/json`.

```txt
  # HELP nodemcu_load Load of the node
  # TYPE nodemcu_load untyped
  nodemcu_load 7.93
  # HELP nodemcu_sensor_value nodemcu_sensor
  # TYPE nodemcu_sensor_value untyped
  nodemcu_sensor_value{name="Humidity"} 37.9
  nodemcu_sensor_value{name="Lux"} 0
  nodemcu_sensor_value{name="Pressure"} 1007
  nodemcu_sensor_value{name="Temperature"} 11.8
```

Je recommande l'utilisation du site [JSONPath Online Evaluator ](https://jsonpath.com/) pour écrire les règles `path`.

### Configuration de prometheus

On ajoute tout cela à la configuration de Prometheus

```yaml
- job_name: json_exporter
    static_configs:
    - targets:
    - node-exporter:7979

- job_name: json_meteo
    metrics_path: /probe
    scrape_interval: 1m
    static_configs:
    - targets:
    - http://<ip-node>/json
    relabel_configs:
    - source_labels: [__address__]
        target_label: __param_target
    - source_labels: [__param_target]
        target_label: instance
    - target_label: __address__
        replacement: node-exporter:7979
```
Cela rend accessibles les valeurs des capteurs sous la forme `nodemcu_sensor_value{name="<nom>}`.