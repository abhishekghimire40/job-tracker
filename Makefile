.PHONY: db-up run build up down migrate-up migrate-down migrate-status migrate-create

# --- Database settings, read from .env (single source of truth) ---
# The shell loads .env (not Make's "include", which treats # as a comment
# and keeps quotes). If .env is missing, e.g. in CI, the POSTGRES_* values
# come from the environment instead.
LOAD_ENV = if [ -f .env ]; then set -a; . ./.env; set +a; fi;

# goose reads GOOSE_* from the environment. DATABASE_URL comes from .env;
# special characters in the password must be URL-encoded there (@ -> %40).
# Passing it this way keeps the password out of `make -n` output.
GOOSE = $(LOAD_ENV) \
	GOOSE_DRIVER=postgres \
	GOOSE_MIGRATION_DIR=migrations \
	GOOSE_DBSTRING="$$DATABASE_URL" \
	go tool goose

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

## migrate-up: apply all pending migrations
migrate-up:
	$(GOOSE) up

## migrate-down: roll back the most recent migration
migrate-down:
	$(GOOSE) down

## migrate-status: list migrations and whether each is applied
migrate-status:
	$(GOOSE) status

## migrate-create: create a new SQL migration, e.g. make migrate-create name=create_posts
migrate-create:
	@test -n "$(name)" || (echo "usage: make migrate-create name=<snake_case_name>" && exit 1)
	mkdir -p migrations/
	$(GOOSE) -s create $(name) sql
