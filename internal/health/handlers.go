package health

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// check the health of the API
func (h *Handler) healthz(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// check the connection to the database
func (h *Handler) readyz(c *gin.Context) {
	// create a timeout of 2sec
	ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
	defer cancel()
	// ping the database
	err := h.dbPool.Ping(ctx)
	if err != nil {
		log.Printf("Database health check failed: %v", err)
		c.JSON(http.StatusServiceUnavailable, gin.H{"status": "down", "message": "Database Connection lost"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
