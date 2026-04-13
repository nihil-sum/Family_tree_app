package handlers

import (
	"chinese-family-tree/internal/db"
	"chinese-family-tree/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// PersonHandler handles HTTP requests for persons
type PersonHandler struct {
	repo *db.PersonRepository
}

// NewPersonHandler creates a new person handler
func NewPersonHandler(repo *db.PersonRepository) *PersonHandler {
	return &PersonHandler{repo: repo}
}

// CreatePerson handles POST /api/persons
func (h *PersonHandler) CreatePerson(c *gin.Context) {
	var req models.CreatePersonRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	person, err := h.repo.Create(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": person})
}

// GetPerson handles GET /api/persons/:id
func (h *PersonHandler) GetPerson(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	person, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Person not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": person})
}

// GetAllPersons handles GET /api/persons
func (h *PersonHandler) GetAllPersons(c *gin.Context) {
	persons, err := h.repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": persons})
}

// UpdatePerson handles PUT /api/persons/:id
func (h *PersonHandler) UpdatePerson(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var req models.UpdatePersonRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	person, err := h.repo.Update(id, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": person})
}

// DeletePerson handles DELETE /api/persons/:id
func (h *PersonHandler) DeletePerson(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := h.repo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Person deleted successfully"})
}

// SearchPersons handles GET /api/persons/search?q=query
func (h *PersonHandler) SearchPersons(c *gin.Context) {
	query := c.DefaultQuery("q", "")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Query parameter 'q' is required"})
		return
	}

	persons, err := h.repo.Search(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": persons, "count": len(persons)})
}

// GetByGenerationName handles GET /api/persons/generation/:name
func (h *PersonHandler) GetByGenerationName(c *gin.Context) {
	name := c.Param("name")
	if name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Generation name is required"})
		return
	}

	persons, err := h.repo.GetByGenerationName(name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": persons, "count": len(persons)})
}

// GetByFamilyName handles GET /api/persons/family/:name
func (h *PersonHandler) GetByFamilyName(c *gin.Context) {
	name := c.Param("name")
	if name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Family name is required"})
		return
	}

	persons, err := h.repo.GetByFamilyName(name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": persons, "count": len(persons)})
}
