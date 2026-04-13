package models

import "time"

// Marriage represents a marriage relationship
type Marriage struct {
	ID            int64     `db:"id" json:"id"`
	UUID          string    `db:"uuid" json:"uuid"`
	HusbandID     int64     `db:"husband_id" json:"husband_id"`
	WifeID        int64     `db:"wife_id" json:"wife_id"`
	MarriageDate  *string   `db:"marriage_date" json:"marriage_date,omitempty"`
	MarriagePlace *string   `db:"marriage_place" json:"marriage_place,omitempty"`
	MarriageType  string    `db:"marriage_type" json:"marriage_type"` // primary, secondary, concubine
	EndDate       *string   `db:"end_date" json:"end_date,omitempty"`
	EndReason     *string   `db:"end_reason" json:"end_reason,omitempty"`
	CreatedAt     time.Time `db:"created_at" json:"created_at"`
}

// CreateMarriageRequest represents the request to create a marriage
type CreateMarriageRequest struct {
	HusbandID     int64   `json:"husband_id" binding:"required"`
	WifeID        int64   `json:"wife_id" binding:"required"`
	MarriageDate  *string `json:"marriage_date,omitempty"`
	MarriagePlace *string `json:"marriage_place,omitempty"`
	MarriageType  string  `json:"marriage_type" binding:"omitempty,oneof=primary secondary concubine"`
	EndDate       *string `json:"end_date,omitempty"`
	EndReason     *string `json:"end_reason,omitempty"`
}

// UpdateMarriageRequest represents the request to update a marriage
type UpdateMarriageRequest struct {
	HusbandID     int64   `json:"husband_id,omitempty"`
	WifeID        int64   `json:"wife_id,omitempty"`
	MarriageDate  *string `json:"marriage_date,omitempty"`
	MarriagePlace *string `json:"marriage_place,omitempty"`
	MarriageType  string  `json:"marriage_type" binding:"omitempty,oneof=primary secondary concubine"`
	EndDate       *string `json:"end_date,omitempty"`
	EndReason     *string `json:"end_reason,omitempty"`
}

// MarriageDetail includes person details
type MarriageDetail struct {
	Marriage
	Husband Person `json:"husband"`
	Wife    Person `json:"wife"`
}
