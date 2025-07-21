package handler

import (
	"net/http"
	"notes/internal/auth"
	"notes/internal/db"
	"notes/internal/model"
	"time"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	// todo
}

func NewHandler() *Handler {
	return &Handler{}
}

func (h *Handler) Test(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"test": "test"})
}

func (h *Handler) RegisterUser(c *gin.Context) {
	var input struct {
		Username        string `json:"username" binding:"required"`
		Password        string `json:"password" binding:"required"`
		PasswordConfirm string `json:"password_confirm" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"status": "error", "message": err.Error()})
		return
	}

	if input.Password != input.PasswordConfirm {
		c.JSON(400, gin.H{"status": "error", "message": "passwords do not match"})
		return
	}

	var countCheckUser int64
	db.DB.Model(&model.User{}).Where("username = ?", input.Username).Count(&countCheckUser)
	if countCheckUser > 0 {
		c.JSON(400, gin.H{"status": "error", "message": "username exists"})
		return
	}

	hashedPassword, err := auth.HashPassword(input.Password)
	if err != nil {
		c.JSON(500, gin.H{"status": "error", "message": "failed hash password"})
		return
	}

	user := model.User{
		Username:  input.Username,
		Password:  hashedPassword,
		CreatedAt: time.Now(),
	}

	if err := db.DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"status": "error", "message": "failed create user"})
		return
	}

	c.JSON(200, gin.H{"status": "success", "message": "user registered success", "id_user": user.ID})
}

func (h *Handler) LoginUser(c *gin.Context) {
	var input struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"status": "error", "message": err.Error()})
		return
	}

	var dbUser model.User
	if err := db.DB.Where("username = ?", input.Username).First(&dbUser).Error; err != nil {
		c.JSON(400, gin.H{"status": "error", "message": "user not found"})
		return
	}

	if !auth.CheckPasswordHash(input.Password, dbUser.Password) {
		c.JSON(400, gin.H{"status": "error", "message": "invalid password"})
		return
	}

	token, err := auth.CreateJWT(dbUser)
	if err != nil {
		c.JSON(500, gin.H{"status": "error", "message": "failed to generate token"})
		return
	}

	c.JSON(200, gin.H{"status": "success", "message": "login success", "token": token})
}
