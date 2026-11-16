# Progress

## Phase 1: Foundation

Done when: one command starts the stack and CI passes.

- [ ] P1-1 Repository set up (git, Go module, folder layout, `.gitignore`)
- [ ] P1-2 Local environment: one command starts the stack (Docker Compose: app + Postgres)
- [ ] P1-3 Database schema managed by versioned migrations (goose), with sqlc generating code
- [ ] P1-4 Health endpoint (Gin) that reports app and database status
- [ ] P1-5 CI running on GitHub Actions (lint, test, container build)
