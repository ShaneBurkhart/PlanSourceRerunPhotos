.PHONY: db

NAME=rerunphotos

all: run

build:
	 docker build -t ${NAME} .

run:
	docker run --rm --env-file user.env -v $(shell pwd):/app ${NAME} /app/rerun-photos.rb
