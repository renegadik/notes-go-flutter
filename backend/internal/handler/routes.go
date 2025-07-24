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
		api.POST("/deleteNote", h.DeleteNote)

		api.POST("/deleteManyNotes", h.DeleteManyNotes)
		api.POST("/pinNote", h.PinNote)
		api.POST("/unpinNote", h.UnpinNote)
		api.POST("/archiveNote", h.ArchiveNote)
		api.POST("/unarchiveNote", h.UnarchiveNote)
		api.POST("getArchivedNotes", h.GetArchivedNotes)
	}
}
