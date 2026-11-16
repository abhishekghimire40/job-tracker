package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// load env file
	err := godotenv.Load(".env")
	if err != nil {
		log.Printf("Missing env file %v", err.Error())
	}

	// get the port from env file or use default
	port := os.Getenv("PORT")
	if port == "" {
		log.Print("port not loaded from env ")
		port = "8080"
	}
	port = fmt.Sprintf(":%s", port)

	router := gin.Default()
	router.GET("/healthz", func(ctx *gin.Context) { ctx.JSON(http.StatusOK, gin.H{"status": "ok"}) })

	// start the server
	err = router.Run(port)
	if err != nil {
		log.Fatalf("couldn't start the router: %v", err.Error())
	}

}
