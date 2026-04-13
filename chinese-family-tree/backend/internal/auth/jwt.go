package auth

import (
	"chinese-family-tree/internal/models"
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret = []byte(os.Getenv("JWT_SECRET"))

// Claims represents the JWT claims
type Claims struct {
	UserID   int64        `json:"userId"`
	Username string       `json:"username"`
	Role     models.UserRole `json:"role"`
	jwt.RegisteredClaims
}

// GenerateToken generates a JWT token for a user
func GenerateToken(user models.User) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour) // Token expires in 24 hours

	claims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "chinese-family-tree-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// GenerateRefreshToken generates a refresh token for a user
func GenerateRefreshToken(user models.User) (string, error) {
	expirationTime := time.Now().Add(7 * 24 * time.Hour) // Refresh token expires in 7 days

	claims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "chinese-family-tree-api-refresh",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// ValidateToken validates a JWT token and returns the claims
func ValidateToken(tokenString string) (*Claims, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}

// HasRole checks if the user has a specific role
func (c *Claims) HasRole(role models.UserRole) bool {
	return c.Role == role
}

// HasPermission checks if the user has permission for a specific action
func (c *Claims) HasPermission(action string) bool {
	switch action {
	case "read":
		return c.Role == models.UserRoleAdmin || 
			   c.Role == models.UserRoleEditor || 
			   c.Role == models.UserRoleViewer ||
			   c.Role == models.UserRoleGuest
	case "create", "update":
		return c.Role == models.UserRoleAdmin || c.Role == models.UserRoleEditor
	case "delete":
		return c.Role == models.UserRoleAdmin
	default:
		return false
	}
}