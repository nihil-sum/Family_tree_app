# Chinese Family Tree (家谱应用)

A full-stack application for building and managing Chinese family trees (家谱/族谱).

Built with **Go** (backend) + **Flutter** (frontend) + **SQLite** (database).

## Features

### Chinese-Specific Support

- ✅ **Generation Names (字辈)** - Track generation poems and assign generation characters
- ✅ **Chinese Naming** - Family name, given name, courtesy name, art name
- ✅ **Birth Order (排行)** - Track 长子 (eldest son), heir status
- ✅ **Historical Marriages** - Support for primary, secondary wives (historical accuracy)
- ✅ **Relationship Types** - Biological, adopted (收养/过继), step, foster
- ✅ **Ancestral Info** - Birth/death dates, burial places (墓地), ancestral homeland (祖籍)

### Standard Genealogy

- ✅ Multi-generational family trees
- ✅ Search and filtering
- ✅ Media attachments (photos, documents)
- ✅ Tags and categories
- ✅ Export/Import (planned)

## Project Structure

```
chinese-family-tree/
├── backend/                 # Go REST API
│   ├── cmd/
│   ├── internal/
│   │   ├── db/             # Database layer
│   │   ├── handlers/       # HTTP handlers
│   │   └── models/         # Data models
│   └── README.md
├── frontend/                # Flutter app (TODO)
├── schema/                  # Database schema
│   └── 001_initial_schema.sql
└── docs/                    # Documentation
    ├── SCHEMA_DESIGN.md
    └── EXAMPLE_DATA.md
```

## Quick Start

### Backend Setup

```bash
cd backend

# Install dependencies
go mod download

# Run the server
go run ./cmd/main.go
```

Server will start on `http://localhost:8080`

### Database

The database is automatically created on first run. Default location: `./family_tree.db`

Configure via environment:

```bash
DATABASE_PATH=./data/family.db go run ./cmd/main.go
```

## API Documentation

See [backend/README.md](backend/README.md) for API endpoints.

### Example: Create a Person

```bash
curl -X POST http://localhost:8080/api/persons \
  -H "Content-Type: application/json" \
  -d '{
    "family_name": "李",
    "given_name": "明",
    "generation_name": "光",
    "gender": "M",
    "birth_date": "1990-01-15"
  }'
```

### Example: Search

```bash
curl "http://localhost:8080/api/persons/search?q=李"
```

## Database Schema

The schema supports:

- **persons** - Individual people with Chinese naming fields
- **marriages** - Spouse relationships
- **parent_child** - Parent-child relationships with birth order
- **generation_poems** - Family generation poems (字辈诗)
- **family_branches** - Family branch/lineage tracking
- **media** - Photos and documents
- **tags** - Categorization

See [docs/SCHEMA_DESIGN.md](docs/SCHEMA_DESIGN.md) for details.

## Roadmap

### Phase 1: Core (In Progress)
- [x] Database schema design
- [x] Go backend setup
- [x] Person CRUD operations
- [ ] Marriage CRUD operations
- [ ] Parent-child relationships
- [ ] Family tree queries

### Phase 2: Flutter Frontend
- [ ] Project setup
- [ ] Person list/detail screens
- [ ] Family tree visualization
- [ ] Add/edit forms
- [ ] Search functionality

### Phase 3: Advanced Features
- [ ] Generation poem management
- [ ] Media upload
- [ ] GEDCOM import/export
- [ ] PDF report generation
- [ ] Multi-user support

### Phase 4: Polish
- [ ] Lunar calendar support
- [ ] Chinese relationship terms
- [ ] Export to traditional 族谱 format
- [ ] Cloud sync

## Tech Stack

**Backend:**
- Go 1.21+
- Gin (web framework)
- SQLx (database)
- SQLite3

**Frontend (Planned):**
- Flutter
- Provider/Riverpod (state management)
- Graph visualization library

## Contributing

This is a personal project, but feel free to fork and adapt!

## License

MIT

---

**家谱传承，源远流长**  
*Preserving family heritage, one generation at a time*
