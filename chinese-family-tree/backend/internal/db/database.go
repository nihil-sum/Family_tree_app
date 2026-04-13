package db

import (
	"fmt"
	"log"

	_ "modernc.org/sqlite"
	"github.com/jmoiron/sqlx"
)

// Database wraps sqlx.DB for our application
type Database struct {
	*sqlx.DB
}

// Config holds database configuration
type Config struct {
	DSN string // Data Source Name (file path for SQLite)
}

// NewDatabase creates a new database connection
func NewDatabase(config Config) (*Database, error) {
	db, err := sqlx.Connect("sqlite", config.DSN)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Enable foreign keys for SQLite
	_, err = db.Exec("PRAGMA foreign_keys = ON")
	if err != nil {
		return nil, fmt.Errorf("failed to enable foreign keys: %w", err)
	}

	log.Println("Database connection established")
	return &Database{db}, nil
}

// Close closes the database connection
func (d *Database) Close() error {
	if d.DB != nil {
		return d.DB.Close()
	}
	return nil
}

// Migrate runs database migrations
func (d *Database) Migrate(migrations []string) error {
	tx, err := d.Beginx()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer func() {
		if err != nil {
			tx.Rollback()
		}
	}()

	for i, migration := range migrations {
		_, err = tx.Exec(migration)
		if err != nil {
			return fmt.Errorf("migration %d failed: %w", i, err)
		}
		log.Printf("Migration %d applied successfully", i)
	}

	err = tx.Commit()
	if err != nil {
		return fmt.Errorf("failed to commit migrations: %w", err)
	}

	log.Println("All migrations applied successfully")
	return nil
}

// NewInMemoryDatabase creates an in-memory database (useful for testing)
func NewInMemoryDatabase() (*Database, error) {
	return NewDatabase(Config{DSN: ":memory:"})
}

// NewFileDatabase creates a database backed by a file
func NewFileDatabase(filePath string) (*Database, error) {
	return NewDatabase(Config{DSN: filePath})
}
