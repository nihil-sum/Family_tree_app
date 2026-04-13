package handlers

import (
	"chinese-family-tree/internal/db"
	"chinese-family-tree/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// ParentChildHandler handles HTTP requests for parent-child relationships
type ParentChildHandler struct {
	repo *db.ParentChildRepository
}

// NewParentChildHandler creates a new parent-child handler
func NewParentChildHandler(repo *db.ParentChildRepository) *ParentChildHandler {
	return &ParentChildHandler{repo: repo}
}

// CreateParentChild handles POST /api/parent-child
func (h *ParentChildHandler) CreateParentChild(c *gin.Context) {
	var req models.CreateParentChildRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	relationship, err := h.repo.Create(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": relationship})
}

// GetParentChild handles GET /api/parent-child/:id
func (h *ParentChildHandler) GetParentChild(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	relationship, err := h.repo.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Relationship not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": relationship})
}

// GetAllParentChild handles GET /api/parent-child
func (h *ParentChildHandler) GetAllParentChild(c *gin.Context) {
	relationships, err := h.repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": relationships})
}

// UpdateParentChild handles PUT /api/parent-child/:id
func (h *ParentChildHandler) UpdateParentChild(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var req models.UpdateParentChildRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	relationship, err := h.repo.Update(id, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": relationship})
}

// DeleteParentChild handles DELETE /api/parent-child/:id
func (h *ParentChildHandler) DeleteParentChild(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := h.repo.Delete(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Relationship deleted successfully"})
}

// GetByChild handles GET /api/parent-child/child/:childId
func (h *ParentChildHandler) GetByChild(c *gin.Context) {
	childID, err := strconv.ParseInt(c.Param("childId"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid child ID"})
		return
	}

	relationships, err := h.repo.GetByChild(childID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": relationships})
}

// GetByParent handles GET /api/parent-child/parent/:parentId
func (h *ParentChildHandler) GetByParent(c *gin.Context) {
	parentID, err := strconv.ParseInt(c.Param("parentId"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid parent ID"})
		return
	}

	relationships, err := h.repo.GetByParent(parentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": relationships})
}