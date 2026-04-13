# Chinese Family Tree - Go Backend

RESTful API backend for the Chinese Family Tree application.

## Quick Start

### Prerequisites

- Go 1.21 or later
- SQLite3 (included via go-sqlite3 driver)

### Installation

```bash
cd backend

# Download dependencies
go mod download

# Build the application
go build -o family-tree-api ./cmd/main.go

# Run the server
./family-tree-api
```

Or run directly:

```bash
go run ./cmd/main.go
```

### Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |
| `DATABASE_PATH` | `./family_tree.db` | SQLite database file path |

Example:

```bash
PORT=3000 DATABASE_PATH=./data/family.db go run ./cmd/main.go
```

## API Endpoints

### Authentication

| Method | Endpoint | Description | Public |
|--------|----------|-------------|---------|
| `POST` | `/api/auth/register` | Register a new user | ✅ Yes |
| `POST` | `/api/auth/login` | Login and get JWT token | ✅ Yes |
| `GET` | `/api/auth/profile` | Get current user profile | ❌ No |
| `PUT` | `/api/auth/profile` | Update current user profile | ❌ No |
| `PUT` | `/api/auth/change-password` | Change current user password | ❌ No |

### User Management (Admin Only)

| Method | Endpoint | Description | Role |
|--------|----------|-------------|------|
| `GET` | `/api/users` | Get all users | `admin` |
| `GET` | `/api/users/:id` | Get specific user | `admin` |
| `PUT` | `/api/users/:id` | Update specific user | `admin` |
| `DELETE` | `/api/users/:id` | Delete specific user | `admin` |

### Persons

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|----------------|
| `POST` | `/api/persons` | Create a person | ✅ Yes |
| `GET` | `/api/persons` | Get all persons | ✅ Yes |
| `GET` | `/api/persons/:id` | Get person by ID | ✅ Yes |
| `PUT` | `/api/persons/:id` | Update person | ✅ Yes |
| `DELETE` | `/api/persons/:id` | Delete person | ✅ Yes |
| `GET` | `/api/persons/search?q=李明` | Search persons | ✅ Yes |
| `GET` | `/api/persons/generation/:name` | Get by generation name | ✅ Yes |
| `GET` | `/api/persons/family/:name` | Get by family name | ✅ Yes |

### Marriages

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|----------------|
| `POST` | `/api/marriages` | Create a marriage | ✅ Yes |
| `GET` | `/api/marriages` | Get all marriages | ✅ Yes |
| `GET` | `/api/marriages/:id` | Get marriage by ID | ✅ Yes |
| `PUT` | `/api/marriages/:id` | Update marriage | ✅ Yes |
| `DELETE` | `/api/marriages/:id` | Delete marriage | ✅ Yes |
| `GET` | `/api/marriages/person/:personId` | Get marriages for a person | ✅ Yes |

### Parent-Child Relationships

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|----------------|
| `POST` | `/api/parent-child` | Create parent-child relationship | ✅ Yes |
| `GET` | `/api/parent-child` | Get all relationships | ✅ Yes |
| `GET` | `/api/parent-child/:id` | Get relationship by ID | ✅ Yes |
| `PUT` | `/api/parent-child/:id` | Update relationship | ✅ Yes |
| `DELETE` | `/api/parent-child/:id` | Delete relationship | ✅ Yes |
| `GET` | `/api/parent-child/child/:childId` | Get parents for a child | ✅ Yes |
| `GET` | `/api/parent-child/parent/:parentId` | Get children for a parent | ✅ Yes |

### Health Check

```bash
curl http://localhost:8080/health
```

## Example Requests

### Create a Person

```bash
curl -X POST http://localhost:8080/api/persons \
  -H "Content-Type: application/json" \
  -d '{
    "family_name": "李",
    "given_name": "明",
    "generation_name": "光",
    "gender": "M",
    "birth_date": "1990-01-15",
    "birth_place": "北京"
  }'
```

### Search Persons

```bash
curl "http://localhost:8080/api/persons/search?q=李"
```

### Get by Generation Name

```bash
curl http://localhost:8080/api/persons/generation/光
```

## Project Structure

```
backend/
├── cmd/
│   └── main.go           # Application entry point
├── internal/
│   ├── db/
│   │   ├── database.go          # Database connection
│   │   └── person_repository.go # Person data access
│   ├── handlers/
│   │   └── person_handler.go    # HTTP handlers
│   └── models/
│       ├── person.go            # Person models
│       ├── marriage.go          # Marriage models
│       ├── parent_child.go      # Parent-child models
│       └── generation.go        # Generation poem models
├── go.mod
└── README.md
```

## Development

### Run Tests

```bash
go test ./...
```

### Format Code

```bash
go fmt ./...
```

### Lint

```bash
go vet ./...
```

## Database Schema

The schema is defined in `../schema/001_initial_schema.sql` and applied automatically on startup.

## Next Steps

- [ ] Add marriage CRUD endpoints
- [ ] Add parent-child relationship endpoints
- [ ] Add generation poem management
- [ ] Add family tree traversal queries
- [ ] Add authentication/authorization
- [ ] Add file upload for media
- [ ] Add GEDCOM import/export
