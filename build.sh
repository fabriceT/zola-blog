#!/bin/env bash

zola build
rsync -av --delete-after public/ www.kill-swit.ch:/home/thfa9713/public_html \
  --exclude ".well-known" \
  --exclude ".htaccess"
