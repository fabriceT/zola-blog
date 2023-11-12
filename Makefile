ifneq (,$(wildcard ./.env))
    include .env
    export
endif

all: build deploy


PHONY: build deploy


build:
	zola build

deploy:
	rsync -rv --delete-after public/ $(ROOT) \
	  --exclude ".well-known" \
	  --exclude ".htaccess"
