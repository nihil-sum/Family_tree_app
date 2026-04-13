# Chinese Family Tree - Database Schema Design

## Overview

This schema is designed specifically for **Chinese genealogy** (家谱/族谱), which has unique requirements compared to Western family trees.

## Key Chinese-Specific Features

### 1. Naming Conventions (姓名)

```
姓 (Family Name) + 名 (Given Name)
Example: 李 (Li) + 明 (Ming) = 李明
```

- **family_name**: The surname, passed down patrilineally
- **given_name**: Personal name chosen by parents
- **generation_name (字辈)**: A character from a family poem indicating generation
- **courtesy_name (字)**: Adult name used in formal settings
- **art_name (号)**: Literary/pseudonym name

### 2. Generation Poems (字辈诗)

Many Chinese families have a poem where each character represents a generation:

```
Example: "正大光明，忠厚传家"
Generation 1: 正
Generation 2: 大
Generation 3: 光
Generation 4: 明
...
```

Children's given names often include their generation character.

### 3. Marriage Structure

Historically supports:
- **Primary wife** (正妻)
- **Secondary wives** (侧室)
- **Concubines** (妾) - for historical records

### 4. Birth Order (排行)

Birth order is **culturally significant**:
- **长子** (eldest son) - primary heir
- **次子** (second son)
- **长女** (eldest daughter)
- etc.

### 5. Relationship Types

- **Biological** (亲生)
- **Adopted** (收养) - including 过继 (adoption within clan)
- **Step** (继)
- **Foster** (寄养)

## Schema Diagram

```
┌──────────────────┐
│     persons      │
│  ─────────────   │
│  id, uuid        │
│  family_name     │
│  given_name      │
│  generation_name │
│  gender, dates   │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌──────────────┐
│marriages│ │ parent_child │
│         │ │              │
│husband  │ │ parent       │
│wife     │ │ child        │
│type     │ │ birth_order  │
└─────────┘ │ is_heir      │
            └──────────────┘
```

## Tables Explained

### `persons`
Core table for individuals. Includes Chinese naming fields and life events.

### `marriages`
Links spouses. Supports multiple marriages per person (historical accuracy).

### `parent_child`
Many-to-many relationship. A child has 2 parents, a parent can have many children.
- `birth_order`: Critical for Chinese families (长子 inheritance)
- `is_heir`: Marks the primary heir

### `generation_poems`
Stores family generation poems for automatic generation name assignment.

### `family_branches`
For large clans with multiple branches (房).

### `media`
Photos, documents, ancestral tablets, etc.

### `tags`
Categorize people (e.g., "科举及第", "移民", "war hero").

## Indexes

Key indexes for performance:
- `family_name`: Quick surname searches
- `generation_name`: Find same-generation cousins
- `parent_child`: Fast tree traversal

## Future Extensions

Consider adding:
- **titles** (官职) - government positions
- **examinations** (科举) - imperial exam results
- **properties** (财产) - family assets
- **stories** (故事) - family legends

## SQLite vs PostgreSQL

This schema uses SQLite syntax (for simplicity). For production:

**SQLite** (default):
- Good for single-user, local apps
- File-based, no server needed

**PostgreSQL** (scale up):
- Better for multi-user, web apps
- Use `SERIAL` instead of `AUTOINCREMENT`
- Add `JSONB` columns for flexible metadata

## Next Steps

1. ✅ Schema design - **DONE**
2. Create Go models (structs)
3. Set up database connection
4. Implement CRUD operations
5. Add migration system

Ready to move to Go backend setup? 🚀
