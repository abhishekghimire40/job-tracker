# --- Build stage: compile the Go binary ---
FROM golang:1.27.2 AS build
WORKDIR /src

# Download dependencies first so this layer is cached until go.mod/go.sum change
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# CGO off -> a static binary that runs on a minimal image
RUN CGO_ENABLED=0 go build -o /out/api ./cmd/api

# --- Runtime stage: only the binary, no Go toolchain or source ---
FROM alpine:3.22
# Alpine has no non-root user by default, so create one
RUN addgroup -S app && adduser -S -G app app
COPY --from=build /out/api /api
ENV GIN_MODE=release
EXPOSE 8080
USER app:app
ENTRYPOINT ["/api"]
