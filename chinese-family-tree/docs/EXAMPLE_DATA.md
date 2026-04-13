# Example Data - Chinese Family Tree

## Sample Family: 李家 (Li Family)

### Generation Poem
```
"正大光明，忠厚传家，仁义礼智"
```

### Family Structure

```
Generation 1 (正): 李正华 + 王氏
                    │
        ┌───────────┼───────────┐
        │           │           │
Generation 2 (大): 李大伟    李大强    李大美
        │           │
    张氏        刘氏
        │           │
    ┌───┴───┐   ┌───┴───┐
    │       │   │       │
Generation 3 (光): 
    李光文  李光明  李光武  李光辉
    (heir)
```

## SQL Insert Examples

```sql
-- Generation poem
INSERT INTO generation_poems (family_name, poem_text, poem_order)
VALUES ('李', '正大光明忠厚传家仁义礼智', 1);

-- Grandfather (Generation 1)
INSERT INTO persons (uuid, family_name, given_name, generation_name, 
                     gender, birth_date, is_deceased)
VALUES ('uuid-1', '李', '正华', '正', 'M', '1920-01-15', TRUE);

-- Grandmother
INSERT INTO persons (uuid, family_name, given_name, gender, birth_date)
VALUES ('uuid-2', '王', '秀英', 'F', '1922-03-20');

-- Their marriage
INSERT INTO marriages (uuid, husband_id, wife_id, marriage_date, marriage_type)
VALUES ('uuid-m1', 1, 2, '1940-06-01', 'primary');

-- Eldest son (Generation 2, birth order 1, heir)
INSERT INTO persons (uuid, family_name, given_name, generation_name, gender)
VALUES ('uuid-3', '李', '大伟', '大', 'M');

-- Link parent-child
INSERT INTO parent_child (child_id, parent_id, marriage_id, birth_order, is_heir)
VALUES (3, 1, 1, 1, TRUE);  -- Son of father
INSERT INTO parent_child (child_id, parent_id, marriage_id, birth_order)
VALUES (3, 2, 1, 1);        -- Son of mother
```

## Query Examples

### Find all descendants of a person
```sql
WITH RECURSIVE descendants AS (
    SELECT id, family_name, given_name, 0 as generation
    FROM persons WHERE id = 1
    UNION ALL
    SELECT p.id, p.family_name, p.given_name, d.generation + 1
    FROM persons p
    JOIN parent_child pc ON p.id = pc.child_id
    JOIN descendants d ON pc.parent_id = d.id
)
SELECT * FROM descendants ORDER BY generation, family_name, given_name;
```

### Find all same-generation cousins
```sql
SELECT p.* 
FROM persons p
WHERE p.generation_name = '光'
  AND p.family_name = '李'
ORDER BY p.birth_date;
```

### Find the family tree with relationships
```sql
SELECT 
    child.full_name as child_name,
    parent.full_name as parent_name,
    pc.birth_order,
    pc.is_heir,
    pc.relationship_type
FROM parent_child pc
JOIN persons child ON pc.child_id = child.id
JOIN persons parent ON pc.parent_id = parent.id
ORDER BY child.family_name, pc.birth_order;
```

## Common Chinese Terms in the Schema

| English | Chinese | Schema Field |
|---------|---------|--------------|
| Surname | 姓 | `family_name` |
| Given name | 名 | `given_name` |
| Generation name | 字辈 | `generation_name` |
| Courtesy name | 字 | `courtesy_name` |
| Eldest son | 长子 | `is_heir = TRUE` |
| Birth order | 排行 | `birth_order` |
| Ancestral home | 祖籍 | `origin_place` |
| Burial place | 墓地 | `burial_place` |
| Adoption | 收养/过继 | `is_adopted`, `relationship_type` |
