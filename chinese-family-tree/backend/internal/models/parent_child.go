package models

import "time"

// ParentChild represents a parent-child relationship
type ParentChild struct {
	ID               int64     `db:"id" json:"id"`
	ChildID          int64     `db:"child_id" json:"child_id"`
	ParentID         int64     `db:"parent_id" json:"parent_id"`
	MarriageID       *int64    `db:"marriage_id" json:"marriage_id,omitempty"`
	RelationshipType string    `db:"relationship_type" json:"relationship_type"` // biological, adopted, step, foster
	BirthOrder       *int      `db:"birth_order" json:"birth_order,omitempty"`
	IsHeir           bool      `db:"is_heir" json:"is_heir"`
	CreatedAt        time.Time `db:"created_at" json:"created_at"`
}

// CreateParentChildRequest represents the request to create a parent-child relationship
type CreateParentChildRequest struct {
	ChildID          int64  `json:"child_id" binding:"required"`
	ParentID         int64  `json:"parent_id" binding:"required"`
	MarriageID       *int64 `json:"marriage_id,omitempty"`
	RelationshipType string `json:"relationship_type" binding:"omitempty,oneof=biological adopted step foster"`
	BirthOrder       *int   `json:"birth_order,omitempty"`
	IsHeir           bool   `json:"is_heir"`
}

// UpdateParentChildRequest represents the request to update a parent-child relationship
type UpdateParentChildRequest struct {
	MarriageID       *int64 `json:"marriage_id,omitempty"`
	RelationshipType string `json:"relationship_type" binding:"omitempty,oneof=biological adopted step foster"`
	BirthOrder       *int   `json:"birth_order,omitempty"`
	IsHeir           *bool  `json:"is_heir,omitempty"`
}

// ParentChildDetail includes person details
type ParentChildDetail struct {
	ParentChild
	Parent Person `json:"parent"`
	Child  Person `json:"child"`
}
