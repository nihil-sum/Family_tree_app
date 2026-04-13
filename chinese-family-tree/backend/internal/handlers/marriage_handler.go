package handlers

import (
	"chinese-family-tree/internal/db"
	"chinese-family-tree/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// MarriageHandler handles HTTP requests for marriages
type MarriageHandler struct {
	repo *db.MarriageRepository
}

// NewMarriageHandler creates a new marriage handler
func NewMarriageHandler(repo *db.MarriageRepository) *MarriageHandler {
	return &MarriageHandler{repo: repo}
}

// CreateMarriage handles POST /api/marriages
func (h *MarriageHandler) CreateMarriage(c *gin.Context) {
	var req models.CreateMarriageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	marriage, err := h.repo.Create(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": marriage})
}

// GetMarriage handles GET /api/marriages/:id
func (h *MarriageHandler) GetMarriage(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	marriage, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Marriage not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": marriage})
}

// GetAllMarriages handles GET /api/marriages
func (h *MarriageHandler) GetAllMarriages(c *gin.Context) {
	marriages, err := h.repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": marriages})
}

// UpdateMarriage handles PUT /api/marriages/:id
func (h *MarriageHandler) UpdateMarriage(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var req models.UpdateMarriageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	marriage, err := h.repo.Update(id, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": marriage})
}

// DeleteMarriage handles DELETE /api/marriages/:id
func (h *MarriageHandler) DeleteMarriage(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := h.repo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Marriage deleted successfully"})
}

// GetMarriagesByPerson handles GET /api/marriages/person/:personId
func (h *MarriageHandler) GetMarriagesByPerson(c *gin.Context) {
	personID, err := strconv.ParseInt(c.Param("personId"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid person ID"})
		return
	}

	marriages, err := h.repo.GetByPerson(personID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": marriages})
}