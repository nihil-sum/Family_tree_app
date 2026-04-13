package db

import (
	"chinese-family-tree/internal/models"
	"fmt"
)

// ParentChildRepository handles parent-child relationship database operations
type ParentChildRepository struct {
	db *Database
}

// NewParentChildRepository creates a new parent-child repository
func NewParentChildRepository(db *Database) *ParentChildRepository {
	return &ParentChildRepository{db: db}
}

// Create creates a new parent-child relationship
func (r *ParentChildRepository) Create(req models.CreateParentChildRequest) (*models.ParentChild, error) {
	relationship := models.ParentChild{
		ChildID:          req.ChildID,
		ParentID:         req.ParentID,
		MarriageID:       req.MarriageID,
		RelationshipType: req.RelationshipType,
		BirthOrder:       req.BirthOrder,
		IsHeir:           req.IsHeir,
	}

	query := `
		INSERT INTO parent_child (
			child_id, parent_id, marriage_id, relationship_type, birth_order, is_heir
		) VALUES (
			:child_id, :parent_id, :marriage_id, :relationship_type, :birth_order, :is_heir
		)`

	result, err := r.db.NamedExec(query, relationship)
	if err != nil {
		return nil, fmt.Errorf("failed to create parent-child relationship: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, fmt.Errorf("failed to get last insert id: %w", err)
	}

	relationship.ID = id
	return &relationship, nil
}

// GetByID retrieves a parent-child relationship by ID
func (r *ParentChildRepository) GetByID(id int64) (*models.ParentChild, error) {
	var relationship models.ParentChild
	err := r.db.Get(&relationship, "SELECT * FROM parent_child WHERE id = ?", id)
	if err != nil {
		return nil, fmt.Errorf("failed to get parent-child relationship: %w", err)
	}
	return &relationship, nil
}

// GetAll retrieves all parent-child relationships
func (r *ParentChildRepository) GetAll() ([]models.ParentChild, error) {
	var relationships []models.ParentChild
	err := r.db.Select(&relationships, "SELECT * FROM parent_child ORDER BY birth_order")
	if err != nil {
		return nil, fmt.Errorf("failed to get all parent-child relationships: %w", err)
	}
	return relationships, nil
}

// GetByChild retrieves all parents for a specific child
func (r *ParentChildRepository) GetByChild(childID int64) ([]models.ParentChild, error) {
	var relationships []models.ParentChild
	err := r.db.Select(&relationships, 
		"SELECT * FROM parent_child WHERE child_id = ? ORDER BY relationship_type", 
		childID)
	if err != nil {
		return nil, fmt.Errorf("failed to get parents for child: %w", err)
	}
	return relationships, nil
}

// GetByParent retrieves all children for a specific parent
func (r *ParentChildRepository) GetByParent(parentID int64) ([]models.ParentChild, error) {
	var relationships []models.ParentChild
	err := r.db.Select(&relationships, 
		"SELECT * FROM parent_child WHERE parent_id = ? ORDER BY birth_order", 
		parentID)
	if err != nil {
		return nil, fmt.Errorf("failed to get children for parent: %w", err)
	}
	return relationships, nil
}

// GetByChildAndParent retrieves a specific parent-child relationship
func (r *ParentChildRepository) GetByChildAndParent(childID, parentID int64) (*models.ParentChild, error) {
	var relationship models.ParentChild
	err := r.db.Get(&relationship, 
		"SELECT * FROM parent_child WHERE child_id = ? AND parent_id = ? LIMIT 1", 
		childID, parentID)
	if err != nil {
		return nil, fmt.Errorf("failed to get parent-child relationship: %w", err)
	}
	return &relationship, nil
}

// Update updates a parent-child relationship
func (r *ParentChildRepository) Update(id int64, req models.UpdateParentChildRequest) (*models.ParentChild, error) {
	// Build dynamic update query
	updates := []string{}
	args := []interface{}{}

	if req.RelationshipType != "" {
		updates = append(updates, "relationship_type = ?")
		args = append(args, req.RelationshipType)
	}
	if req.BirthOrder != nil {
		updates = append(updates, "birth_order = ?")
		args = append(args, *req.BirthOrder)
	}
	if req.IsHeir != nil {
		updates = append(updates, "is_heir = ?")
		args = append(args, *req.IsHeir)
	}
	if req.MarriageID != nil {
		updates = append(updates, "marriage_id = ?")
		args = append(args, *req.MarriageID)
	}

	if len(updates) == 0 {
		return r.GetByID(id)
	}

	args = append(args, id)
	query := fmt.Sprintf("UPDATE parent_child SET %s WHERE id = ?", 
		joinStrings(updates, ", "))

	_, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update parent-child relationship: %w", err)
	}

	return r.GetByID(id)
}

// Delete deletes a parent-child relationship
func (r *ParentChildRepository) Delete(id int64) error {
	_, err := r.db.Exec("DELETE FROM parent_child WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete parent-child relationship: %w", err)
	}
	return nil
}

// DeleteByChildAndParent deletes a specific parent-child relationship
func (r *ParentChildRepository) DeleteByChildAndParent(childID, parentID int64) error {
	_, err := r.db.Exec("DELETE FROM parent_child WHERE child_id = ? AND parent_id = ?", childID, parentID)
	if err != nil {
		return fmt.Errorf("failed to delete parent-child relationship: %w", err)
	}
	return nil
}