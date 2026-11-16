.PHONY: db-up run build up down

## db-up: start only Postgres in the background (leave it running)
db-up:
	docker compose up -d db

## run: run the API on your machine against the Postgres container
run:
	go run ./cmd/api

## build: compile the API into bin/
build:
	go build -o bin/api ./cmd/api

## up: build and start the whole stack (Postgres + API) in Docker
up:
	docker compose up --build -d

## down: stop the stack (data stays in the pgdata volume; add -v to wipe it)
down:
	docker compose down
