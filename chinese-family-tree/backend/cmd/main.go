package main

import (
	"chinese-family-tree/internal/auth"
	"chinese-family-tree/internal/db"
	"chinese-family-tree/internal/handlers"
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	// Get database path from environment or use default
	dbPath := os.Getenv("DATABASE_PATH")
	if dbPath == "" {
		dbPath = "./family_tree.db"
	}

	// Initialize database
	database, err := db.NewFileDatabase(dbPath)
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Run migrations
	if err := runMigrations(database); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	// Initialize repositories
	personRepo := db.NewPersonRepository(database)
	marriageRepo := db.NewMarriageRepository(database)
	parentChildRepo := db.NewParentChildRepository(database)
	userRepo := db.NewUserRepository(database)

	// Initialize handlers
	personHandler := handlers.NewPersonHandler(personRepo)
	marriageHandler := handlers.NewMarriageHandler(marriageRepo)
	parentChildHandler := handlers.NewParentChildHandler(parentChildRepo)
	userHandler := handlers.NewUserHandler(userRepo)

	// Setup Gin router
	r := gin.Default()

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// API routes
	api := r.Group("/api")
	{
		// Person routes
		persons := api.Group("/persons")
		{
			persons.POST("", personHandler.CreatePerson)
			persons.GET("", personHandler.GetAllPersons)
			persons.GET("/:id", personHandler.GetPerson)
			persons.PUT("/:id", personHandler.UpdatePerson)
			persons.DELETE("/:id", personHandler.DeletePerson)
			persons.GET("/search", personHandler.SearchPersons)
			persons.GET("/generation/:name", personHandler.GetByGenerationName)
			persons.GET("/family/:name", personHandler.GetByFamilyName)
		}

		// Marriage routes
		marriages := api.Group("/marriages")
		{
			marriages.POST("", marriageHandler.CreateMarriage)
			marriages.GET("", marriageHandler.GetAllMarriages)
			marriages.GET("/:id", marriageHandler.GetMarriage)
			marriages.PUT("/:id", marriageHandler.UpdateMarriage)
			marriages.DELETE("/:id", marriageHandler.DeleteMarriage)
			marriages.GET("/person/:personId", marriageHandler.GetMarriagesByPerson)
		}

		// Parent-child relationship routes
		parentChild := api.Group("/parent-child")
		{
			parentChild.POST("", parentChildHandler.CreateParentChild)
			parentChild.GET("", parentChildHandler.GetAllParentChild)
			parentChild.GET("/:id", parentChildHandler.GetParentChild)
			parentChild.PUT("/:id", parentChildHandler.UpdateParentChild)
			parentChild.DELETE("/:id", parentChildHandler.DeleteParentChild)
			parentChild.GET("/child/:childId", parentChildHandler.GetByChild)
			parentChild.GET("/parent/:parentId", parentChildHandler.GetByParent)
		}


		// User management routes
		users := api.Group("/users")
		{
			users.GET("/:id", auth.PermissionRequired("read"), userHandler.GetUser)
			users.GET("", auth.PermissionRequired("read"), userHandler.GetAllUsers)
			users.PUT("/:id", auth.PermissionRequired("create"), userHandler.UpdateUser)
			users.DELETE("/:id", auth.PermissionRequired("delete"), userHandler.DeleteUser)
		}

		// Authentication routes
		authGroup := api.Group("/auth")
		{
			authGroup.POST("/register", userHandler.Register)
			authGroup.POST("/login", userHandler.Login)
			authGroup.GET("/profile", auth.AuthMiddleware(), userHandler.GetProfile)
			authGroup.PUT("/profile", auth.AuthMiddleware(), userHandler.UpdateProfile)
			authGroup.PUT("/change-password", auth.AuthMiddleware(), userHandler.ChangePassword)
		}

		// TODO: Add generation poem routes
	}

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s...", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// runMigrations applies database schema migrations
func runMigrations(database *db.Database) error {
	migrations := []string{
		// Persons table
		`CREATE TABLE IF NOT EXISTS persons (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid            TEXT UNIQUE NOT NULL,
			family_name     TEXT NOT NULL,
			given_name      TEXT NOT NULL,
			full_name       TEXT,
			generation_name TEXT,
			courtesy_name   TEXT,
			art_name        TEXT,
			english_name    TEXT,
			gender          TEXT CHECK (gender IN ('M', 'F', 'U')),
			birth_date      TEXT,
			birth_date_lunar TEXT,
			birth_place     TEXT,
			death_date      TEXT,
			death_place     TEXT,
			burial_place    TEXT,
			is_deceased     BOOLEAN DEFAULT FALSE,
			is_adopted      BOOLEAN DEFAULT FALSE,
			biography       TEXT,
			achievements    TEXT,
			occupation      TEXT,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(family_name, given_name, birth_date)
		)`,

		// Indexes
		`CREATE INDEX IF NOT EXISTS idx_persons_family_name ON persons(family_name)`,
		`CREATE INDEX IF NOT EXISTS idx_persons_generation ON persons(generation_name)`,

		// Marriages table
		`CREATE TABLE IF NOT EXISTS marriages (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid            TEXT UNIQUE NOT NULL,
			husband_id      INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
			wife_id         INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
			marriage_date   TEXT,
			marriage_place  TEXT,
			marriage_type   TEXT DEFAULT 'primary',
			end_date        TEXT,
			end_reason      TEXT,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(husband_id, wife_id, marriage_date)
		)`,

		// Parent-child table
		`CREATE TABLE IF NOT EXISTS parent_child (
			id                INTEGER PRIMARY KEY AUTOINCREMENT,
			child_id          INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
			parent_id         INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
			marriage_id       INTEGER REFERENCES marriages(id),
			relationship_type TEXT DEFAULT 'biological',
			birth_order       INTEGER,
			is_heir           BOOLEAN DEFAULT FALSE,
			created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(child_id, parent_id, relationship_type)
		)`,

		// Generation poems table
		`CREATE TABLE IF NOT EXISTS generation_poems (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			family_name     TEXT NOT NULL,
			branch_name     TEXT,
			poem_text       TEXT NOT NULL,
			poem_order      INTEGER NOT NULL,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(family_name, branch_name, poem_order)
		)`,

		// Family branches table
		`CREATE TABLE IF NOT EXISTS family_branches (
			id                 INTEGER PRIMARY KEY AUTOINCREMENT,
			family_name        TEXT NOT NULL,
			branch_name        TEXT,
			founder_id         INTEGER REFERENCES persons(id),
			origin_place       TEXT,
			generation_poem_id INTEGER REFERENCES generation_poems(id),
			created_at         DATETIME DEFAULT CURRENT_TIMESTAMP
		)`,

		// Media table
		`CREATE TABLE IF NOT EXISTS media (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid            TEXT UNIQUE NOT NULL,
			person_id       INTEGER REFERENCES persons(id) ON DELETE CASCADE,
			marriage_id     INTEGER REFERENCES marriages(id) ON DELETE CASCADE,
			media_type      TEXT NOT NULL,
			file_path       TEXT NOT NULL,
			file_name       TEXT NOT NULL,
			mime_type       TEXT,
			file_size       INTEGER,
			description     TEXT,
			date_taken      TEXT,
			location        TEXT,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
		)`,

		// Tags table
		`CREATE TABLE IF NOT EXISTS tags (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			name            TEXT UNIQUE NOT NULL,
			color           TEXT,
			description     TEXT
		)`,

		// Person-tags junction table
		`CREATE TABLE IF NOT EXISTS person_tags (
			person_id       INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
			tag_id          INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY (person_id, tag_id)
		)`,

			// Trigger for updated_at
		`CREATE TRIGGER IF NOT EXISTS update_persons_timestamp 
		AFTER UPDATE ON persons
		BEGIN
			UPDATE persons SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
		END`,

		// Users table
		`CREATE TABLE IF NOT EXISTS users (
			id              INTEGER PRIMARY KEY AUTOINCREMENT,
			uuid            TEXT UNIQUE NOT NULL,
			username        TEXT UNIQUE NOT NULL,
			email           TEXT UNIQUE NOT NULL,
			password        TEXT NOT NULL,
			role            TEXT NOT NULL DEFAULT 'viewer',
			display_name    TEXT NOT NULL,
			is_active       BOOLEAN DEFAULT TRUE,
			created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
			updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP
		)`,

		// Indexes for users
		`CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)`,
		`CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)`,
		`CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)`,
	}

	return database.Migrate(migrations)
}
