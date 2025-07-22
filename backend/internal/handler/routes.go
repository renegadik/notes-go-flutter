package handler

import (
	"notes/internal/auth"

	"github.com/gin-gonic/gin"
)

func InitRoutes(r *gin.Engine, jwtSecret string) {
	h := NewHandler()

	r.POST("/login", h.LoginUser)
	r.POST("/register", h.RegisterUser)

	api := r.Group("/api")
	api.Use(auth.AuthMiddleware(jwtSecret))
	{
		api.POST("/createNote", h.CreateNote)
		api.POST("/getAllUserNotes", h.GetUserNotes)
		api.POST("/getNoteById", h.GetNoteById)
		api.POST("/updateNote", h.UpdateNote)
	}
}
