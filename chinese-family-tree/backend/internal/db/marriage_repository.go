package db

import (
	"chinese-family-tree/internal/models"
	"fmt"

	"github.com/google/uuid"
)

// MarriageRepository handles marriage-related database operations
type MarriageRepository struct {
	db *Database
}

// NewMarriageRepository creates a new marriage repository
func NewMarriageRepository(db *Database) *MarriageRepository {
	return &MarriageRepository{db: db}
}

// Create creates a new marriage
func (r *MarriageRepository) Create(req models.CreateMarriageRequest) (*models.Marriage, error) {
	marriage := models.Marriage{
		UUID:          uuid.New().String(),
		HusbandID:     req.HusbandID,
		WifeID:        req.WifeID,
		MarriageDate:  req.MarriageDate,
		MarriagePlace: req.MarriagePlace,
		MarriageType:  req.MarriageType,
		EndDate:       req.EndDate,
		EndReason:     req.EndReason,
	}

	query := `
		INSERT INTO marriages (
			uuid, husband_id, wife_id, marriage_date, marriage_place, 
			marriage_type, end_date, end_reason
		) VALUES (
			:uuid, :husband_id, :wife_id, :marriage_date, :marriage_place,
			:marriage_type, :end_date, :end_reason
		)`

	result, err := r.db.NamedExec(query, marriage)
	if err != nil {
		return nil, fmt.Errorf("failed to create marriage: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, fmt.Errorf("failed to get last insert id: %w", err)
	}

	marriage.ID = id
	return &marriage, nil
}

// GetByID retrieves a marriage by ID
func (r *MarriageRepository) GetByID(id int64) (*models.Marriage, error) {
	var marriage models.Marriage
	err := r.db.Get(&marriage, "SELECT * FROM marriages WHERE id = ?", id)
	if err != nil {
		return nil, fmt.Errorf("failed to get marriage: %w", err)
	}
	return &marriage, nil
}

// GetAll retrieves all marriages
func (r *MarriageRepository) GetAll() ([]models.Marriage, error) {
	var marriages []models.Marriage
	err := r.db.Select(&marriages, "SELECT * FROM marriages ORDER BY marriage_date")
	if err != nil {
		return nil, fmt.Errorf("failed to get all marriages: %w", err)
	}
	return marriages, nil
}

// Update updates a marriage
func (r *MarriageRepository) Update(id int64, req models.UpdateMarriageRequest) (*models.Marriage, error) {
	// Build dynamic update query
	updates := []string{}
	args := []interface{}{}

	if req.HusbandID != 0 {
		updates = append(updates, "husband_id = ?")
		args = append(args, req.HusbandID)
	}
	if req.WifeID != 0 {
		updates = append(updates, "wife_id = ?")
		args = append(args, req.WifeID)
	}
	if req.MarriageDate != nil {
		updates = append(updates, "marriage_date = ?")
		args = append(args, *req.MarriageDate)
	}
	if req.MarriagePlace != nil {
		updates = append(updates, "marriage_place = ?")
		args = append(args, *req.MarriagePlace)
	}
	if req.MarriageType != "" {
		updates = append(updates, "marriage_type = ?")
		args = append(args, req.MarriageType)
	}
	if req.EndDate != nil {
		updates = append(updates, "end_date = ?")
		args = append(args, *req.EndDate)
	}
	if req.EndReason != nil {
		updates = append(updates, "end_reason = ?")
		args = append(args, *req.EndReason)
	}

	if len(updates) == 0 {
		return r.GetByID(id)
	}

	args = append(args, id)
	query := fmt.Sprintf("UPDATE marriages SET %s WHERE id = ?", 
		joinStrings(updates, ", "))

	_, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update marriage: %w", err)
	}

	return r.GetByID(id)
}

// Delete deletes a marriage
func (r *MarriageRepository) Delete(id int64) error {
	_, err := r.db.Exec("DELETE FROM marriages WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete marriage: %w", err)
	}
	return nil
}

// GetByPerson retrieves all marriages for a person
func (r *MarriageRepository) GetByPerson(personID int64) ([]models.Marriage, error) {
	var marriages []models.Marriage
	
	// Get marriages where person is husband or wife
	query := `
		SELECT * FROM marriages 
		WHERE husband_id = ? OR wife_id = ?
		ORDER BY marriage_date`
	
	err := r.db.Select(&marriages, query, personID, personID)
	if err != nil {
		return nil, fmt.Errorf("failed to get marriages for person: %w", err)
	}
	return marriages, nil
}

// GetByHusband retrieves marriages for a specific husband
func (r *MarriageRepository) GetByHusband(husbandID int64) ([]models.Marriage, error) {
	var marriages []models.Marriage
	err := r.db.Select(&marriages, 
		"SELECT * FROM marriages WHERE husband_id = ? ORDER BY marriage_date", 
		husbandID)
	if err != nil {
		return nil, fmt.Errorf("failed to get marriages by husband: %w", err)
	}
	return marriages, nil
}

// GetByWife retrieves marriages for a specific wife
func (r *MarriageRepository) GetByWife(wifeID int64) ([]models.Marriage, error) {
	var marriages []models.Marriage
	err := r.db.Select(&marriages, 
		"SELECT * FROM marriages WHERE wife_id = ? ORDER BY marriage_date", 
		wifeID)
	if err != nil {
		return nil, fmt.Errorf("failed to get marriages by wife: %w", err)
	}
	return marriages, nil
}