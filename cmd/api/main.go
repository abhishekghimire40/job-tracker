package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/abhishekghimire40/job-tracker/internal/health"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func run() error {
	ctx := context.Background()
	// load env file
	err := godotenv.Load(".env")
	if err != nil {
		log.Printf("missing env file %v", err.Error())
	}

	// get the port from env file or use default
	port := os.Getenv("PORT")
	if port == "" {
		log.Print("port not loaded from env")
		port = "8080"
	}
	port = fmt.Sprintf(":%s", port)

	// get the database connection string from  the environment
	dbConnString := os.Getenv("DATABASE_URL")
	if dbConnString == "" {
		return fmt.Errorf("database url : DATABASE_URL is not set")
	}

	//initialize database connection
	pool, err := pgxpool.New(ctx, dbConnString)
	if err != nil {
		return fmt.Errorf("creating pool: %w", err)
	}
	defer pool.Close()

	// intialize server router
	router := gin.Default()

	// healthcheck routes
	healthHandler := health.NewHandler(pool)
	healthHandler.RegisterRoutes(router)

	// start the server
	err = router.Run(port)
	if err != nil {
		return fmt.Errorf("router run: %w", err)
	}
	return nil
}

func main() {
	err := run()
	if err != nil {
		log.Fatalf("Err: %v", err)
	}
}
