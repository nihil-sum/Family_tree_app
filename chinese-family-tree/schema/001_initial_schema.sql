-- Chinese Family Tree Database Schema
-- Supports traditional Chinese genealogy features

-- ============================================
-- CORE TABLES
-- ============================================

-- People table: stores individual person records
CREATE TABLE IF NOT EXISTS persons (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT UNIQUE NOT NULL,
    
    -- Names (Chinese naming conventions)
    family_name     TEXT NOT NULL,           -- 姓 (surname)
    given_name      TEXT NOT NULL,           -- 名 (given name)
    full_name       TEXT GENERATED ALWAYS AS (family_name || given_name) STORED,
    generation_name TEXT,                    -- 字辈 (generation name/poem character)
    courtesy_name   TEXT,                    -- 字 (courtesy name, for adults)
    art_name        TEXT,                    -- 号 (art/literary name)
    english_name    TEXT,                    -- Western name if applicable
    
    -- Gender (important for traditional lineage)
    gender          TEXT CHECK (gender IN ('M', 'F', 'U')),
    
    -- Life dates
    birth_date      TEXT,                    -- ISO 8601 date or approximate
    birth_date_lunar TEXT,                   -- Lunar calendar birth date
    birth_place     TEXT,
    death_date      TEXT,
    death_place     TEXT,
    burial_place    TEXT,                    -- 墓地 (burial location)
    
    -- Life status
    is_deceased     BOOLEAN DEFAULT FALSE,
    is_adopted      BOOLEAN DEFAULT FALSE,
    
    -- Biographical info
    biography       TEXT,
    achievements    TEXT,
    occupation      TEXT,
    
    -- Metadata
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for common queries
    UNIQUE(family_name, given_name, birth_date)
);

CREATE INDEX IF NOT EXISTS idx_persons_family_name ON persons(family_name);
CREATE INDEX IF NOT EXISTS idx_persons_generation ON persons(generation_name);

-- ============================================
-- MARRIAGE TABLE (supports polygamy historically)
-- ============================================

CREATE TABLE IF NOT EXISTS marriages (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT UNIQUE NOT NULL,
    
    -- Spouses
    husband_id      INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    wife_id         INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    
    -- Marriage details
    marriage_date   TEXT,
    marriage_place  TEXT,
    marriage_type   TEXT DEFAULT 'primary',  -- primary, secondary, concubine (historical)
    
    -- Marriage status
    end_date        TEXT,                    -- Divorce or death
    end_reason      TEXT,                    -- divorce, death, separation
    
    -- Metadata
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(husband_id, wife_id, marriage_date)
);

CREATE INDEX IF NOT EXISTS idx_marriages_husband ON marriages(husband_id);
CREATE INDEX IF NOT EXISTS idx_marriages_wife ON marriages(wife_id);

-- ============================================
-- PARENT-CHILD RELATIONSHIPS
-- ============================================

CREATE TABLE IF NOT EXISTS parent_child (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    
    child_id        INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    parent_id       INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    marriage_id     INTEGER REFERENCES marriages(id),  -- Links to which marriage
    
    -- Relationship type
    relationship_type TEXT DEFAULT 'biological',  -- biological, adopted, step, foster
    
    -- Birth order within the marriage (important in Chinese culture)
    birth_order     INTEGER,                   -- 1st, 2nd, 3rd child, etc.
    
    -- Whether this child is the heir (长子 - eldest son)
    is_heir         BOOLEAN DEFAULT FALSE,
    
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(child_id, parent_id, relationship_type)
);

CREATE INDEX IF NOT EXISTS idx_parent_child_child ON parent_child(child_id);
CREATE INDEX IF NOT EXISTS idx_parent_child_parent ON parent_child(parent_id);

-- ============================================
-- GENERATION POEM (字辈诗)
-- ============================================

CREATE TABLE IF NOT EXISTS generation_poems (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    family_name     TEXT NOT NULL,
    branch_name     TEXT,                      -- For different family branches
    
    -- The poem (each character represents a generation)
    poem_text       TEXT NOT NULL,
    poem_order      INTEGER NOT NULL,          -- Which character in the poem
    
    -- Metadata
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(family_name, branch_name, poem_order)
);

-- ============================================
-- FAMILY BRANCHES / LINEAGES
-- ============================================

CREATE TABLE IF NOT EXISTS family_branches (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    family_name     TEXT NOT NULL,
    branch_name     TEXT,
    
    -- Ancestral founder of this branch
    founder_id      INTEGER REFERENCES persons(id),
    
    -- Geographic origin
    origin_place    TEXT,                      -- 祖籍 (ancestral homeland)
    
    -- Branch poem if different from main family
    generation_poem_id INTEGER REFERENCES generation_poems(id),
    
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- MEDIA ATTACHMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS media (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT UNIQUE NOT NULL,
    
    person_id       INTEGER REFERENCES persons(id) ON DELETE CASCADE,
    marriage_id     INTEGER REFERENCES marriages(id) ON DELETE CASCADE,
    
    media_type      TEXT NOT NULL,             -- photo, document, audio, video
    file_path       TEXT NOT NULL,
    file_name       TEXT NOT NULL,
    mime_type       TEXT,
    file_size       INTEGER,
    
    -- Description
    description     TEXT,
    date_taken      TEXT,
    location        TEXT,
    
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_media_person ON media(person_id);

-- ============================================
-- TAGS / CATEGORIES
-- ============================================

CREATE TABLE IF NOT EXISTS tags (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT UNIQUE NOT NULL,
    color           TEXT,
    description     TEXT
);

CREATE TABLE IF NOT EXISTS person_tags (
    person_id       INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    tag_id          INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (person_id, tag_id)
);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE TRIGGER IF NOT EXISTS update_persons_timestamp 
AFTER UPDATE ON persons
BEGIN
    UPDATE persons SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
