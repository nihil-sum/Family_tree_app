package models

import (
	"time"
)

// UserRole represents user roles in the system
type UserRole string

const (
	UserRoleAdmin   UserRole = "admin"
	UserRoleEditor  UserRole = "editor"
	UserRoleViewer  UserRole = "viewer"
	UserRoleGuest   UserRole = "guest"
)

// User represents a user in the system
type User struct {
	ID          int64      `db:"id" json:"id"`
	UUID        string     `db:"uuid" json:"uuid"`
	Username    string     `db:"username" json:"username"`
	Email       string     `db:"email" json:"email"`
	Password    string     `db:"password" json:"-"` // Never send password in JSON
	Role        UserRole   `db:"role" json:"role"`
	DisplayName string     `db:"display_name" json:"displayName"`
	IsActive    bool       `db:"is_active" json:"isActive"`
	CreatedAt   time.Time  `db:"created_at" json:"createdAt"`
	UpdatedAt   time.Time  `db:"updated_at" json:"updatedAt"`
}

// CreateUserRequest represents the request to create a user
type CreateUserRequest struct {
	Username    string `json:"username" binding:"required,min=3,max=50"`
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=8"`
	DisplayName string `json:"displayName" binding:"required,min=1,max=100"`
	Role        string `json:"role" binding:"required,oneof=admin editor viewer guest"`
}

// LoginRequest represents the login request
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents the login response
type LoginResponse struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refreshToken"`
	User         User   `json:"user"`
}

// UpdateUserRequest represents the request to update a user
type UpdateUserRequest struct {
	Username    *string `json:"username,omitempty" binding:"omitempty,min=3,max=50"`
	Email       *string `json:"email,omitempty" binding:"omitempty,email"`
	Password    *string `json:"password,omitempty" binding:"omitempty,min=8"`
	DisplayName *string `json:"displayName,omitempty" binding:"omitempty,min=1,max=100"`
	Role        *string `json:"role,omitempty" binding:"omitempty,oneof=admin editor viewer guest"`
	IsActive    *bool   `json:"isActive,omitempty"`
}

// ChangePasswordRequest represents the password change request
type ChangePasswordRequest struct {
	OldPassword string `json:"oldPassword" binding:"required"`
	NewPassword string `json:"newPassword" binding:"required,min=8"`
}