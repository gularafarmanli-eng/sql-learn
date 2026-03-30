# MySQL vs PostgreSQL: Quick Reference Guide

This guide highlights the key syntax differences between MySQL and PostgreSQL that you'll encounter during the SQL lessons.

---

## Data Types

| Concept | PostgreSQL | MySQL |
|---------|------------|-------|
| Auto-increment PK | `SERIAL` or `INT GENERATED ALWAYS AS IDENTITY` | `INT AUTO_INCREMENT` |
| Boolean | `BOOLEAN` (TRUE/FALSE) | `BOOLEAN` or `TINYINT(1)` (1/0) |
| Text (unlimited) | `TEXT` | `TEXT` |
| JSON | `JSON` or `JSONB` (binary, faster) | `JSON` |
| UUID | `UUID` | `CHAR(36)` or `BINARY(16)` |
| IP Address | `INET` | `VARCHAR(45)` |

---

## String Operations

| Operation | PostgreSQL | MySQL |
|-----------|------------|-------|
| Concatenation | `'Hello' \|\| ' ' \|\| 'World'` | `CONCAT('Hello', ' ', 'World')` |
| String length | `LENGTH('text')` or `CHAR_LENGTH('text')` | `LENGTH('text')` or `CHAR_LENGTH('text')` |
| Substring | `SUBSTRING(str FROM 1 FOR 5)` | `SUBSTRING(str, 1, 5)` |
| Case-insensitive LIKE | `ILIKE '%pattern%'` | `LIKE '%pattern%'` (default) |
| Case-sensitive LIKE | `LIKE '%pattern%'` | `LIKE BINARY '%pattern%'` |

---

## Date and Time

| Operation | PostgreSQL | MySQL |
|-----------|------------|-------|
| Current timestamp | `CURRENT_TIMESTAMP` or `NOW()` | `CURRENT_TIMESTAMP` or `NOW()` |
| Current date | `CURRENT_DATE` | `CURDATE()` or `CURRENT_DATE` |
| Date truncation | `DATE_TRUNC('month', timestamp)` | `DATE_FORMAT(timestamp, '%Y-%m-01')` |
| Extract part | `EXTRACT(YEAR FROM timestamp)` | `YEAR(timestamp)` or `EXTRACT(YEAR FROM timestamp)` |
| Add interval | `timestamp + INTERVAL '1 day'` | `timestamp + INTERVAL 1 DAY` |
| Date difference | `date1 - date2` (returns integer) | `DATEDIFF(date1, date2)` |

### Examples

```sql
-- PostgreSQL: Get first day of month
SELECT DATE_TRUNC('month', CURRENT_DATE) AS first_of_month;

-- MySQL: Get first day of month
SELECT DATE_FORMAT(CURDATE(), '%Y-%m-01') AS first_of_month;

-- PostgreSQL: Records from last 30 days
SELECT * FROM events
WHERE created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days';

-- MySQL: Records from last 30 days
SELECT * FROM events
WHERE created_at >= NOW() - INTERVAL 30 DAY;
```

---

## LIMIT and Pagination

| Operation | PostgreSQL | MySQL |
|-----------|------------|-------|
| Limit rows | `LIMIT 10` | `LIMIT 10` |
| Skip rows | `OFFSET 20` | `OFFSET 20` |
| Combined | `LIMIT 10 OFFSET 20` | `LIMIT 10 OFFSET 20` or `LIMIT 20, 10` |

```sql
-- Both databases (standard SQL)
SELECT * FROM players ORDER BY player_id LIMIT 10 OFFSET 20;

-- MySQL alternative syntax
SELECT * FROM players ORDER BY player_id LIMIT 20, 10; -- LIMIT offset, count
```

---

## UPSERT (Insert or Update)

### PostgreSQL: ON CONFLICT

```sql
INSERT INTO daily_stats (player_id, stat_date, total_score)
VALUES (1, CURRENT_DATE, 100)
ON CONFLICT (player_id, stat_date)
DO UPDATE SET
    total_score = daily_stats.total_score + EXCLUDED.total_score;
```

### MySQL: ON DUPLICATE KEY UPDATE

```sql
INSERT INTO daily_stats (player_id, stat_date, total_score)
VALUES (1, CURDATE(), 100)
ON DUPLICATE KEY UPDATE
    total_score = total_score + VALUES(total_score);
```

---

## Boolean Handling

```sql
-- PostgreSQL: Native boolean
SELECT * FROM games WHERE is_multiplayer = TRUE;
SELECT * FROM games WHERE is_multiplayer;  -- Implicit true check

-- MySQL: Boolean is stored as TINYINT(1)
SELECT * FROM games WHERE is_multiplayer = TRUE;
SELECT * FROM games WHERE is_multiplayer = 1;  -- Also works
```

---

## String Aggregation

### PostgreSQL: STRING_AGG

```sql
SELECT
    game_id,
    STRING_AGG(username, ', ' ORDER BY username) AS player_list
FROM game_sessions gs
JOIN players p ON gs.player_id = p.player_id
GROUP BY game_id;
```

### MySQL: GROUP_CONCAT

```sql
SELECT
    game_id,
    GROUP_CONCAT(username ORDER BY username SEPARATOR ', ') AS player_list
FROM game_sessions gs
JOIN players p ON gs.player_id = p.player_id
GROUP BY game_id;
```

---

## JSON Operations

### PostgreSQL (JSONB recommended)

```sql
-- Extract value
SELECT event_data->>'action' AS action FROM event_logs;

-- Extract nested value
SELECT event_data->'user'->>'name' AS user_name FROM event_logs;

-- Cast JSON value
SELECT (event_data->>'amount')::INT AS amount FROM event_logs;

-- Build JSON object
SELECT JSON_BUILD_OBJECT('name', username, 'id', player_id) FROM players;

-- Aggregate as JSON array
SELECT JSON_AGG(username) FROM players;
```

### MySQL

```sql
-- Extract value
SELECT JSON_EXTRACT(event_data, '$.action') AS action FROM event_logs;
SELECT event_data->>'$.action' AS action FROM event_logs;  -- MySQL 8.0+

-- Extract nested value
SELECT JSON_EXTRACT(event_data, '$.user.name') AS user_name FROM event_logs;

-- Build JSON object
SELECT JSON_OBJECT('name', username, 'id', player_id) FROM players;

-- Aggregate as JSON array
SELECT JSON_ARRAYAGG(username) FROM players;
```

---

## Common Table Expressions (CTEs)

Both databases support CTEs with the same syntax:

```sql
WITH active_players AS (
    SELECT * FROM players WHERE account_status = 'active'
)
SELECT * FROM active_players WHERE subscription_tier = 'vip';
```

**Recursive CTEs** also work the same way in both databases (MySQL 8.0+):

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;
```

---

## Window Functions

Both databases support window functions with the same syntax (MySQL 8.0+):

```sql
SELECT
    username,
    total_playtime_minutes,
    ROW_NUMBER() OVER (ORDER BY total_playtime_minutes DESC) AS rank,
    SUM(total_playtime_minutes) OVER () AS total_all_players
FROM players;
```

---

## Full Outer Join

### PostgreSQL: Native support

```sql
SELECT *
FROM table_a a
FULL OUTER JOIN table_b b ON a.id = b.id;
```

### MySQL: Emulate with UNION

```sql
SELECT * FROM table_a a LEFT JOIN table_b b ON a.id = b.id
UNION
SELECT * FROM table_a a RIGHT JOIN table_b b ON a.id = b.id;
```

---

## Show Tables and Schema

| Operation | PostgreSQL | MySQL |
|-----------|------------|-------|
| List tables | `\dt` or query `information_schema.tables` | `SHOW TABLES;` |
| Describe table | `\d table_name` | `DESCRIBE table_name;` |
| Show create | `pg_dump -t table_name --schema-only` | `SHOW CREATE TABLE table_name;` |

```sql
-- PostgreSQL: List all tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- MySQL: List all tables
SHOW TABLES;

-- Both: Describe table structure
-- PostgreSQL
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'players';

-- MySQL
DESCRIBE players;
```

---

## Identifier Quoting

| Database | Quote Character | Example |
|----------|-----------------|---------|
| PostgreSQL | Double quotes `"` | `SELECT "Column Name" FROM "Table Name"` |
| MySQL | Backticks `` ` `` | `` SELECT `Column Name` FROM `Table Name` `` |

---

## Quick Tips

1. **PostgreSQL is case-sensitive** for quoted identifiers, MySQL is case-insensitive by default

2. **PostgreSQL uses `::` for type casting**, MySQL uses `CAST()`:
   ```sql
   -- PostgreSQL
   SELECT '100'::INT;

   -- MySQL
   SELECT CAST('100' AS SIGNED);
   ```

3. **PostgreSQL has better JSON support** with JSONB (binary storage, indexable)

4. **Both support transactions** with `BEGIN`, `COMMIT`, `ROLLBACK`

5. **MySQL requires `ENGINE=InnoDB`** for transactions (default in MySQL 8.0+)

---

## Recommended Practices

1. **Write portable SQL** when possible by using standard SQL syntax
2. **Use CTEs** instead of complex subqueries (supported in both)
3. **Prefer explicit JOINs** over implicit comma-separated tables
4. **Use parameterized queries** to prevent SQL injection (application level)
5. **Test queries** on both databases when building cross-compatible code
