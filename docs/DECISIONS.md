# DECISIONS

## Folder layout

## Phase 1 decisions

| Decision               | Options compared                                                               | Pick                                          | Reason                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------ | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Language               | Python, Go, TypeScript                                                         | Go (Python possibly later for Phase 5/6)      | Chose go as i am familiar with it and wanted to build and API on that , had python as my second choice which i may use it for MCP integrations |
| Database               | PostgreSQL, SQLite, MySQL                                                      | PostgreSQL                                    | i have been using postgres for some time so i am familiar with it, and it also has good vector search |
| DB access + migrations | ORM with its migrations, raw SQL + migration runner, query builder / typed SQL | goose (migrations) + sqlc (typed Go from SQL) | i have used both before; goose makes migrations easy and sqlc helps catch issues early with queries |
| CI                     | GitHub Actions, GitLab CI                                                      | GitHub Actions                                | widely popular and wanted to learn it                                                                                                          |
| MCP server language    | Go, Python calling the REST API, defer                                         | Deferred to Phase 5                           | MCP language defered to Phase-5 as i am not sure which language to use right now                                                               |
| Web framework          | net/http, chi, Gin, Fiber, Huma                                                | Gin                                           | Gin's parsing and validation leave more time for engineering the product                                                                       |
| Package grouping       | by layer, by feature                                                           | by feature (leaning)                          | by feature is better if we need to add or remove a feature later |
| Folder layout | `cmd/` + `internal/`, flat, folder per language | `cmd/` + `internal/` | i went with standard go layout of cmd/ + internal/ with every feature getting it own folder so that its Easy to add or remove a feature later |
| Loading `.env` | godotenv, Makefile `include`, none | godotenv | simple to start with and i have been using it a lot |
| Reading config | `os.Getenv`, `caarlos0/env`, Viper | `os.Getenv` | simple to start with and i have been using it a lot |
| Missing `.env` | stop, log and continue, load only in dev | log and continue; stop only when a required value is missing | |
| Health route | `/health`, `/healthz`, `/v1/health` | `/healthz` (outside `/v1`) | it just checks if the server is up and alright or not, so it doesn't need versioning |
| Dev setup | all in Compose, Postgres only in Compose, both | Postgres + app in Compose, daily work through `make` | run postgres with docker compose and leave it running; app is in docker too, but i will mostly run it using make cause it is easy to test |
| Postgres version | 16, 17, 18 | 16 | its a normal project and there are more resources for it if we ever get into any problem |
| Database data | named volume, no volume | named volume | so that we don't have to download the data again and again and set up the database, extra work we can avoid |
| Runtime image | distroless, alpine | alpine | it gives me something to debug when i get an error or something goes wrong |
| Installing goose | `tool` directive in `go.mod`, `go install` per machine, run in Docker | `tool` directive (`go tool goose`) | so that everyone gets the version of goose we are using and uses the same one in every environment |
| Migrations location | `migrations/` at root, `internal/db/migrations/` (embedded), `db/migrations/` | `migrations/` at root, sqlc queries in a central `queries/` folder later | migrations only need to run once as a separate step, so there is no need to copy them into our build; and all the queries are in one central place |
| DB connection string for goose | Makefile builds it from `POSTGRES_*`, full `DATABASE_URL` in `.env`, pass on command line | full `DATABASE_URL` in `.env` | its easy for setting and using |
| Missing `migrations/` folder | create it by hand once, `mkdir -p` in `migrate-create` | `mkdir -p` in `migrate-create` | so that we never face this error, as it creates the directory if it isn't there |
| Migration file naming | timestamps (goose default), sequential (`-s`) | sequential | it helps me check which one was the first migration and follow them carefully |
| Thread primary key | HN thread ID, surrogate UUID/serial + unique HN ID | HN thread ID (`INTEGER`) | it is already unique, so there is no need to add an extra column for that |
| Thread month | one `DATE` (1st of month), `year` + `month` columns | `DATE NOT NULL UNIQUE` with `CHECK` that the day is 1 | so the same month is never saved twice; the code sets the date to the first of the month and the database check catches it if the day isn't 1 |
| Thread month source | thread title, post timestamp, both | extract from both; if they match, save the first of that month (what to do on a mismatch is decided in Phase 2) | if we miss it from one we can get it from the other one, or check if both of them don't match |
| raw_posts primary key | HN ID only, UUID with `gen_random_uuid()` + unique `source_id` | UUID with database default, `source_id` `UNIQUE NOT NULL` | using the default postgres uuid would be better cause it won't replicate the same UUID later |
| Raw post content | only the `text` field, full HN item as `JSONB` | full item as `JSONB NOT NULL` | so it keeps its shape when we transform and refine the comment post |
| Deleted posts | flag column, read `deleted` from the JSONB | `is_deleted BOOLEAN NOT NULL DEFAULT false`; `author` and `posted_at` nullable | somebody can delete the comment, and then HN may not return the author and posted date for that comment id |
