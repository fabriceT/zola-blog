all: build deploy


PHONY: build deploy


build:
	zola build

deploy:
	rsync -av --delete-after public/ www.kill-swit.ch:/home/thfa9713/public_html \
	  --exclude ".well-known" \
	  --exclude ".htaccess"
