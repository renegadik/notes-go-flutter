package auth

import (
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func AuthMiddleware(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(401, gin.H{"status": "error", "message": "authorization header missing"})
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(401, gin.H{"status": "error", "message": "format error"})
			c.Abort()
			return
		}

		token := parts[1]
		payload, err := VerifyJWT(token, secret)
		if err != nil {
			c.JSON(401, gin.H{"status": "error", "message": "invalid token: " + err.Error()})
			c.Abort()
			return
		}

		if userID, ok := payload["id"].(float64); ok {
			c.Set("userID", uint(userID))
		} else {
			c.JSON(401, gin.H{"status": "error", "message": "Invalid token payload"})
			c.Abort()
			return
		}

		c.Next()
	}
}
