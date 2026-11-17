

-- name: GetThreadByID :one
SELECT id,month FROM thread
WHERE id = $1;


