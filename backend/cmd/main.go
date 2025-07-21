package main

import (
	"notes/internal/db"
	"notes/internal/handler"
	"notes/internal/middleware"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	db.InitDB()
	jwtSecret := os.Getenv("JWT_SECRET")

	r := gin.Default()
	r.Use(middleware.CORSMiddleware())

	handler.InitRoutes(r, jwtSecret)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}
