package db

import (
	"chinese-family-tree/internal/models"
	"fmt"

	"github.com/google/uuid"
)

// PersonRepository handles person-related database operations
type PersonRepository struct {
	db *Database
}

// NewPersonRepository creates a new person repository
func NewPersonRepository(db *Database) *PersonRepository {
	return &PersonRepository{db: db}
}

// Create creates a new person
func (r *PersonRepository) Create(req models.CreatePersonRequest) (*models.Person, error) {
	person := models.Person{
		UUID:            uuid.New().String(),
		FamilyName:      req.FamilyName,
		GivenName:       req.GivenName,
		GenerationName:  req.GenerationName,
		CourtesyName:    req.CourtesyName,
		ArtName:         req.ArtName,
		EnglishName:     req.EnglishName,
		Gender:          req.Gender,
		BirthDate:       req.BirthDate,
		BirthDateLunar:  req.BirthDateLunar,
		BirthPlace:      req.BirthPlace,
		DeathDate:       req.DeathDate,
		DeathPlace:      req.DeathPlace,
		BurialPlace:     req.BurialPlace,
		IsDeceased:      req.IsDeceased,
		IsAdopted:       req.IsAdopted,
		Biography:       req.Biography,
		Achievements:    req.Achievements,
		Occupation:      req.Occupation,
	}

	query := `
		INSERT INTO persons (
			uuid, family_name, given_name, generation_name, courtesy_name, art_name,
			english_name, gender, birth_date, birth_date_lunar, birth_place,
			death_date, death_place, burial_place, is_deceased, is_adopted,
			biography, achievements, occupation
		) VALUES (
			:uuid, :family_name, :given_name, :generation_name, :courtesy_name, :art_name,
			:english_name, :gender, :birth_date, :birth_date_lunar, :birth_place,
			:death_date, :death_place, :burial_place, :is_deceased, :is_adopted,
			:biography, :achievements, :occupation
		)`

	result, err := r.db.NamedExec(query, person)
	if err != nil {
		return nil, fmt.Errorf("failed to create person: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, fmt.Errorf("failed to get last insert id: %w", err)
	}

	person.ID = id
	return &person, nil
}

// GetByID retrieves a person by ID
func (r *PersonRepository) GetByID(id int64) (*models.Person, error) {
	var person models.Person
	err := r.db.Get(&person, "SELECT * FROM persons WHERE id = ?", id)
	if err != nil {
		return nil, fmt.Errorf("failed to get person: %w", err)
	}
	return &person, nil
}

// GetByUUID retrieves a person by UUID
func (r *PersonRepository) GetByUUID(uuid string) (*models.Person, error) {
	var person models.Person
	err := r.db.Get(&person, "SELECT * FROM persons WHERE uuid = ?", uuid)
	if err != nil {
		return nil, fmt.Errorf("failed to get person by UUID: %w", err)
	}
	return &person, nil
}

// GetAll retrieves all persons
func (r *PersonRepository) GetAll() ([]models.Person, error) {
	var persons []models.Person
	err := r.db.Select(&persons, "SELECT * FROM persons ORDER BY family_name, given_name")
	if err != nil {
		return nil, fmt.Errorf("failed to get all persons: %w", err)
	}
	return persons, nil
}

// Update updates a person
func (r *PersonRepository) Update(id int64, req models.UpdatePersonRequest) (*models.Person, error) {
	// Build dynamic update query
	updates := []string{}
	args := []interface{}{}

	if req.FamilyName != nil {
		updates = append(updates, "family_name = ?")
		args = append(args, *req.FamilyName)
	}
	if req.GivenName != nil {
		updates = append(updates, "given_name = ?")
		args = append(args, *req.GivenName)
	}
	if req.GenerationName != nil {
		updates = append(updates, "generation_name = ?")
		args = append(args, *req.GenerationName)
	}
	if req.CourtesyName != nil {
		updates = append(updates, "courtesy_name = ?")
		args = append(args, *req.CourtesyName)
	}
	if req.ArtName != nil {
		updates = append(updates, "art_name = ?")
		args = append(args, *req.ArtName)
	}
	if req.EnglishName != nil {
		updates = append(updates, "english_name = ?")
		args = append(args, *req.EnglishName)
	}
	if req.Gender != nil {
		updates = append(updates, "gender = ?")
		args = append(args, *req.Gender)
	}
	if req.BirthDate != nil {
		updates = append(updates, "birth_date = ?")
		args = append(args, *req.BirthDate)
	}
	if req.BirthDateLunar != nil {
		updates = append(updates, "birth_date_lunar = ?")
		args = append(args, *req.BirthDateLunar)
	}
	if req.BirthPlace != nil {
		updates = append(updates, "birth_place = ?")
		args = append(args, *req.BirthPlace)
	}
	if req.DeathDate != nil {
		updates = append(updates, "death_date = ?")
		args = append(args, *req.DeathDate)
	}
	if req.DeathPlace != nil {
		updates = append(updates, "death_place = ?")
		args = append(args, *req.DeathPlace)
	}
	if req.BurialPlace != nil {
		updates = append(updates, "burial_place = ?")
		args = append(args, *req.BurialPlace)
	}
	if req.IsDeceased != nil {
		updates = append(updates, "is_deceased = ?")
		args = append(args, *req.IsDeceased)
	}
	if req.IsAdopted != nil {
		updates = append(updates, "is_adopted = ?")
		args = append(args, *req.IsAdopted)
	}
	if req.Biography != nil {
		updates = append(updates, "biography = ?")
		args = append(args, *req.Biography)
	}
	if req.Achievements != nil {
		updates = append(updates, "achievements = ?")
		args = append(args, *req.Achievements)
	}
	if req.Occupation != nil {
		updates = append(updates, "occupation = ?")
		args = append(args, *req.Occupation)
	}

	if len(updates) == 0 {
		return r.GetByID(id)
	}

	args = append(args, id)
	query := fmt.Sprintf("UPDATE persons SET %s WHERE id = ?", 
		joinStrings(updates, ", "))

	_, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update person: %w", err)
	}

	return r.GetByID(id)
}

// Delete deletes a person
func (r *PersonRepository) Delete(id int64) error {
	_, err := r.db.Exec("DELETE FROM persons WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete person: %w", err)
	}
	return nil
}

// Search searches for persons by name
func (r *PersonRepository) Search(query string) ([]models.Person, error) {
	var persons []models.Person
	searchPattern := "%" + query + "%"
	err := r.db.Select(&persons, `
		SELECT * FROM persons 
		WHERE family_name LIKE ? OR given_name LIKE ? OR full_name LIKE ?
		ORDER BY family_name, given_name
	`, searchPattern, searchPattern, searchPattern)
	if err != nil {
		return nil, fmt.Errorf("failed to search persons: %w", err)
	}
	return persons, nil
}

// GetByGenerationName retrieves persons by generation name
func (r *PersonRepository) GetByGenerationName(generationName string) ([]models.Person, error) {
	var persons []models.Person
	err := r.db.Select(&persons, 
		"SELECT * FROM persons WHERE generation_name = ? ORDER BY birth_date", 
		generationName)
	if err != nil {
		return nil, fmt.Errorf("failed to get persons by generation: %w", err)
	}
	return persons, nil
}

// GetByFamilyName retrieves persons by family name
func (r *PersonRepository) GetByFamilyName(familyName string) ([]models.Person, error) {
	var persons []models.Person
	err := r.db.Select(&persons, 
		"SELECT * FROM persons WHERE family_name = ? ORDER BY given_name", 
		familyName)
	if err != nil {
		return nil, fmt.Errorf("failed to get persons by family name: %w", err)
	}
	return persons, nil
}

// Helper function to join strings
func joinStrings(strs []string, sep string) string {
	if len(strs) == 0 {
		return ""
	}
	result := strs[0]
	for i := 1; i < len(strs); i++ {
		result += sep + strs[i]
	}
	return result
}
