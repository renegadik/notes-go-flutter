package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"notes/internal/model"
	"os"
	"strings"
	"time"
)

func base64UrlEncode(data []byte) string {
	s := base64.URLEncoding.EncodeToString(data)
	return strings.TrimRight(s, "=")
}

func base64UrlDecode(s string) ([]byte, error) {
	switch len(s) % 4 {
	case 2:
		s += "=="
	case 3:
		s += "="
	}
	return base64.URLEncoding.DecodeString(s)
}

func signMessage(message, secret string) string {
	key := []byte(secret)
	mac := hmac.New(sha256.New, key)
	mac.Write([]byte(message))
	signature := mac.Sum(nil)
	return base64UrlEncode(signature)
}

func CreateJWT(userData model.User) (string, error) {
	secretKey := os.Getenv("JWT_SECRET")

	header := map[string]string{
		"alg": "HS256",
		"typ": "JWT",
	}

	payload := map[string]interface{}{
		"id":       userData.ID,
		"username": userData.Username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	}

	headerJSON, _ := json.Marshal(header)
	payloadJSON, _ := json.Marshal(payload)

	headerBase64 := base64UrlEncode(headerJSON)
	payloadBase64 := base64UrlEncode(payloadJSON)

	message := headerBase64 + "." + payloadBase64
	signature := signMessage(message, secretKey)

	token := message + "." + signature

	return token, nil
}

func VerifyJWT(token, secret string) (map[string]interface{}, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return nil, errors.New("invalid token format")
	}

	headerB64, payloadB64, signatureB64 := parts[0], parts[1], parts[2]

	message := headerB64 + "." + payloadB64

	expectedSig := signMessage(message, secret)
	if !hmac.Equal([]byte(signatureB64), []byte(expectedSig)) {
		return nil, errors.New("invalid signature")
	}

	payloadBytes, err := base64UrlDecode(payloadB64)
	if err != nil {
		return nil, errors.New("cannot decode payload")
	}

	var payload map[string]interface{}
	err = json.Unmarshal(payloadBytes, &payload)
	if err != nil {
		return nil, errors.New("invalid payload json")
	}

	if expVal, ok := payload["exp"]; ok {
		switch exp := expVal.(type) {
		case float64:
			if time.Now().Unix() > int64(exp) {
				return nil, errors.New("token expired")
			}
		default:
			return nil, errors.New("invalid exp claim")
		}
	} else {
		return nil, errors.New("no exp claim")
	}

	return payload, nil
}
