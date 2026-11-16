# DECISIONS

## Folder layout

## Phase 1 decisions

| Decision               | Options compared                                                               | Pick                                          | Reason                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------------------------ | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Language               | Python, Go, TypeScript                                                         | Go (Python possibly later for Phase 5/6)      | Chose go as i am familiar with it and wanted to build and API on that , had python as my second choice which i may use it for MCP integrations |
| Database               | PostgreSQL, SQLite, MySQL                                                      | PostgreSQL                                    |                                                                                                                                                |
| DB access + migrations | ORM with its migrations, raw SQL + migration runner, query builder / typed SQL | goose (migrations) + sqlc (typed Go from SQL) |                                                                                                                                                |
| CI                     | GitHub Actions, GitLab CI                                                      | GitHub Actions                                | widely popular and wanted to learn it                                                                                                          |
| MCP server language    | Go, Python calling the REST API, defer                                         | Deferred to Phase 5                           | MCP language defered to Phase-5 as i am now sure which language to use right now                                                               |
| Web framework          | net/http, chi, Gin, Fiber, Huma                                                | Gin                                           | Gin's parsing and validation leave more time for engineering the product                                                                       |
| Package grouping       | by layer, by feature                                                           | by feature (leaning)                          |                                                                                                                                                |
| Folder layout | `cmd/` + `internal/`, flat, folder per language | `cmd/` + `internal/` | i went with standard go layout of cmd/ + internal/ with every feature getting it own folder so that its Easy to add or remove a feature later |
| Loading `.env` | godotenv, Makefile `include`, none | godotenv | |
| Reading config | `os.Getenv`, `caarlos0/env`, Viper | `os.Getenv` | |
| Missing `.env` | stop, log and continue, load only in dev | log and continue; stop only when a required value is missing | |
| Health route | `/health`, `/healthz`, `/v1/health` | `/healthz` (outside `/v1`) | |
