package models

import "time"

// Person represents an individual in the family tree
type Person struct {
	ID              int64      `db:"id" json:"id"`
	UUID            string     `db:"uuid" json:"uuid"`
	FamilyName      string     `db:"family_name" json:"family_name"`      // 姓
	GivenName       string     `db:"given_name" json:"given_name"`        // 名
	FullName        string     `db:"full_name" json:"full_name"`          // 姓名 (computed)
	GenerationName  *string    `db:"generation_name" json:"generation_name,omitempty"` // 字辈
	CourtesyName    *string    `db:"courtesy_name" json:"courtesy_name,omitempty"`     // 字
	ArtName         *string    `db:"art_name" json:"art_name,omitempty"`               // 号
	EnglishName     *string    `db:"english_name" json:"english_name,omitempty"`
	Gender          string     `db:"gender" json:"gender"`                // M, F, U
	BirthDate       *string    `db:"birth_date" json:"birth_date,omitempty"`
	BirthDateLunar  *string    `db:"birth_date_lunar" json:"birth_date_lunar,omitempty"` // 农历
	BirthPlace      *string    `db:"birth_place" json:"birth_place,omitempty"`
	DeathDate       *string    `db:"death_date" json:"death_date,omitempty"`
	DeathPlace      *string    `db:"death_place" json:"death_place,omitempty"`
	BurialPlace     *string    `db:"burial_place" json:"burial_place,omitempty"` // 墓地
	IsDeceased      bool       `db:"is_deceased" json:"is_deceased"`
	IsAdopted       bool       `db:"is_adopted" json:"is_adopted"`
	Biography       *string    `db:"biography" json:"biography,omitempty"`
	Achievements    *string    `db:"achievements" json:"achievements,omitempty"`
	Occupation      *string    `db:"occupation" json:"occupation,omitempty"`
	CreatedAt       time.Time  `db:"created_at" json:"created_at"`
	UpdatedAt       time.Time  `db:"updated_at" json:"updated_at"`
}

// CreatePersonRequest represents the request to create a person
type CreatePersonRequest struct {
	FamilyName      string  `json:"family_name" binding:"required"`
	GivenName       string  `json:"given_name" binding:"required"`
	GenerationName  *string `json:"generation_name,omitempty"`
	CourtesyName    *string `json:"courtesy_name,omitempty"`
	ArtName         *string `json:"art_name,omitempty"`
	EnglishName     *string `json:"english_name,omitempty"`
	Gender          string  `json:"gender" binding:"required,oneof=M F U"`
	BirthDate       *string `json:"birth_date,omitempty"`
	BirthDateLunar  *string `json:"birth_date_lunar,omitempty"`
	BirthPlace      *string `json:"birth_place,omitempty"`
	DeathDate       *string `json:"death_date,omitempty"`
	DeathPlace      *string `json:"death_place,omitempty"`
	BurialPlace     *string `json:"burial_place,omitempty"`
	IsDeceased      bool    `json:"is_deceased"`
	IsAdopted       bool    `json:"is_adopted"`
	Biography       *string `json:"biography,omitempty"`
	Achievements    *string `json:"achievements,omitempty"`
	Occupation      *string `json:"occupation,omitempty"`
}

// UpdatePersonRequest represents the request to update a person
type UpdatePersonRequest struct {
	FamilyName      *string `json:"family_name,omitempty"`
	GivenName       *string `json:"given_name,omitempty"`
	GenerationName  *string `json:"generation_name,omitempty"`
	CourtesyName    *string `json:"courtesy_name,omitempty"`
	ArtName         *string `json:"art_name,omitempty"`
	EnglishName     *string `json:"english_name,omitempty"`
	Gender          *string `json:"gender,omitempty" binding:"omitempty,oneof=M F U"`
	BirthDate       *string `json:"birth_date,omitempty"`
	BirthDateLunar  *string `json:"birth_date_lunar,omitempty"`
	BirthPlace      *string `json:"birth_place,omitempty"`
	DeathDate       *string `json:"death_date,omitempty"`
	DeathPlace      *string `json:"death_place,omitempty"`
	BurialPlace     *string `json:"burial_place,omitempty"`
	IsDeceased      *bool   `json:"is_deceased,omitempty"`
	IsAdopted       *bool   `json:"is_adopted,omitempty"`
	Biography       *string `json:"biography,omitempty"`
	Achievements    *string `json:"achievements,omitempty"`
	Occupation      *string `json:"occupation,omitempty"`
}

// PersonWithRelations includes related people
type PersonWithRelations struct {
	Person
	Parents       []Person        `json:"parents,omitempty"`
	Spouses       []SpouseInfo    `json:"spouses,omitempty"`
	Children      []ChildInfo     `json:"children,omitempty"`
	Siblings      []Person        `json:"siblings,omitempty"`
}

// SpouseInfo represents a spouse relationship
type SpouseInfo struct {
	Spouse        Person   `json:"spouse"`
	MarriageID    int64    `json:"marriage_id"`
	MarriageDate  *string  `json:"marriage_date,omitempty"`
	MarriageType  string   `json:"marriage_type"`
	EndDate       *string  `json:"end_date,omitempty"`
	EndReason     *string  `json:"end_reason,omitempty"`
}

// ChildInfo represents a child relationship
type ChildInfo struct {
	Child          Person   `json:"child"`
	RelationshipType string `json:"relationship_type"`
	BirthOrder     *int     `json:"birth_order,omitempty"`
	IsHeir         bool     `json:"is_heir"`
}
