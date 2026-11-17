package health

import (
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

// struct that stores needed depenceny for this package
type Handler struct {
	dbPool *pgxpool.Pool
}

// functoin that initializes our health handler with dependencies
func NewHandler(dbPool *pgxpool.Pool) *Handler {
	return &Handler{
		dbPool: dbPool,
	}
}

// method to register routes for health package
func (h *Handler) RegisterRoutes(r gin.IRouter) {
	r.GET("/healthz", h.healthz)
	r.GET("/readyz", h.readyz)
}
