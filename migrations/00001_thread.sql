-- +goose Up
CREATE TABLE thread (
    id INTEGER PRIMARY KEY,
    month DATE NOT NULL UNIQUE CHECK (EXTRACT(DAY FROM month) = 1)
);

CREATE TABLE raw_posts (
    id UUID PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
    source_id INTEGER UNIQUE NOT NULL,
    parent_id INTEGER NOT NULL REFERENCES thread (id),
    raw_posts_comment JSONB NOT NULL,
    posted_at TIMESTAMPTZ,
    author TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT false
);

-- +goose Down
DROP TABLE IF EXISTS raw_posts;
DROP TABLE IF EXISTS thread;
