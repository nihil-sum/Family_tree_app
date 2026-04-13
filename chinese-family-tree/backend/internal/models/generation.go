package models

import "time"

// GenerationPoem represents a family generation poem (字辈诗)
type GenerationPoem struct {
	ID           int64     `db:"id" json:"id"`
	FamilyName   string    `db:"family_name" json:"family_name"`
	BranchName   *string   `db:"branch_name" json:"branch_name,omitempty"`
	PoemText     string    `db:"poem_text" json:"poem_text"`
	PoemOrder    int       `db:"poem_order" json:"poem_order"`
	CreatedAt    time.Time `db:"created_at" json:"created_at"`
}

// CreateGenerationPoemRequest represents the request to create a generation poem
type CreateGenerationPoemRequest struct {
	FamilyName string  `json:"family_name" binding:"required"`
	BranchName *string `json:"branch_name,omitempty"`
	PoemText   string  `json:"poem_text" binding:"required"`
	PoemOrder  int     `json:"poem_order" binding:"required,min=1"`
}

// FamilyBranch represents a family branch/lineage (家族分支)
type FamilyBranch struct {
	ID                 int64     `db:"id" json:"id"`
	FamilyName         string    `db:"family_name" json:"family_name"`
	BranchName         *string   `db:"branch_name" json:"branch_name,omitempty"`
	FounderID          *int64    `db:"founder_id" json:"founder_id,omitempty"`
	OriginPlace        *string   `db:"origin_place" json:"origin_place,omitempty"` // 祖籍
	GenerationPoemID   *int64    `db:"generation_poem_id" json:"generation_poem_id,omitempty"`
	CreatedAt          time.Time `db:"created_at" json:"created_at"`
}

// CreateFamilyBranchRequest represents the request to create a family branch
type CreateFamilyBranchRequest struct {
	FamilyName       string  `json:"family_name" binding:"required"`
	BranchName       *string `json:"branch_name,omitempty"`
	FounderID        *int64  `json:"founder_id,omitempty"`
	OriginPlace      *string `json:"origin_place,omitempty"`
	GenerationPoemID *int64  `json:"generation_poem_id,omitempty"`
}

// GetGenerationCharacter returns the generation character for a given order
func (gp *GenerationPoem) GetGenerationCharacter(order int) rune {
	if order < 1 || order > len(gp.PoemText) {
		return 0
	}
	return rune(gp.PoemText[order-1])
}
