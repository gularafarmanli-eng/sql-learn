# SQL for Data Engineers: Zero to Hero

A comprehensive 3-lesson SQL curriculum designed for Data Engineers, using a game application database (GameVerse) with both MySQL and PostgreSQL.

---

## Quick Start

### 1. Prerequisites

- Docker and Docker Compose installed
- A SQL client (or use the included Adminer web UI)

### 2. Setup

```bash
# Clone or navigate to this directory
cd sql-learn

# Create your environment file
cp .env.example .env

# Edit .env and set your passwords
# IMPORTANT: Change the default passwords!

# Start the databases
docker compose up -d

# Check that containers are running
docker compose ps
```

### 3. Access the Databases

**Adminer (Web UI):** http://localhost:8080

| Database | Server | Username | Password | Database |
|----------|--------|----------|----------|----------|
| PostgreSQL | `postgres` | `gameadmin` | (from .env) | `gameverse` |
| MySQL | `mysql` | `gameadmin` | (from .env) | `gameverse` |

**Command Line:**

```bash
# PostgreSQL
docker exec -it sql-learn-postgres psql -U gameadmin -d gameverse

# MySQL
docker exec -it sql-learn-mysql mysql -u gameadmin -p gameverse
```

### 4. Start Learning

Open the lesson files in order:
1. [Lesson 1: SQL Fundamentals](lessons/01-fundamentals/README.md)
2. [Lesson 2: Intermediate SQL](lessons/02-intermediate/README.md)
3. [Lesson 3: Advanced SQL](lessons/03-advanced/README.md)

---

## Curriculum Overview

| Lesson | Duration | Topics |
|--------|----------|--------|
| **1. Fundamentals** | 45 min | SELECT, WHERE, ORDER BY, LIMIT, INSERT/UPDATE/DELETE |
| **2. Intermediate** | 45 min | JOINs, Aggregations, GROUP BY, HAVING, Subqueries |
| **3. Advanced** | 45 min | Window Functions, CTEs, Normalization, Query Optimization |

---

## Database: GameVerse

A multiplayer gaming platform database with 14 tables:

```
Core Tables:
├── players              # User accounts
├── games                # Game catalog
├── game_sessions        # Play sessions
├── scores               # Player scores
├── achievements         # Available achievements
├── player_achievements  # Earned achievements
├── items                # In-game items
├── inventory            # Player inventory
├── transactions         # Purchases
├── friendships          # Social connections
├── guilds               # Player groups
├── guild_members        # Guild membership
├── event_logs           # Raw events (ETL practice)
└── daily_player_stats   # Aggregated metrics
```

---

## Project Structure

```
sql-learn/
├── docker-compose.yml          # Database containers
├── .env.example                # Environment template
├── .gitignore
├── README.md                   # This file
│
├── scripts/
│   ├── init-postgres.sql       # PostgreSQL schema + data
│   └── init-mysql.sql          # MySQL schema + data
│
├── lessons/
│   ├── 01-fundamentals/
│   │   ├── README.md           # Concepts
│   │   ├── examples.sql        # Example queries
│   │   └── exercises.sql       # Practice + solutions
│   │
│   ├── 02-intermediate/
│   │   ├── README.md
│   │   ├── examples.sql
│   │   └── exercises.sql
│   │
│   └── 03-advanced/
│       ├── README.md
│       ├── examples.sql
│       └── exercises.sql
│
└── reference/
    └── mysql-vs-postgres.md    # Syntax differences
```

---

## Common Commands

### Docker

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f

# Reset databases (removes all data!)
docker compose down -v
docker compose up -d
```

### PostgreSQL

```bash
# Connect via docker
docker exec -it sql-learn-postgres psql -U gameadmin -d gameverse

# List tables
\dt

# Describe table
\d players

# Run SQL file
\i /path/to/file.sql

# Exit
\q
```

### MySQL

```bash
# Connect via docker
docker exec -it sql-learn-mysql mysql -u gameadmin -p gameverse

# List tables
SHOW TABLES;

# Describe table
DESCRIBE players;

# Exit
exit
```

---

## Learning Tips

1. **Run every example** - Don't just read, execute the queries
2. **Modify queries** - Change conditions, columns, limits
3. **Use EXPLAIN** - Understand how queries execute
4. **Practice exercises** - Try before looking at solutions
5. **Compare databases** - Run queries on both MySQL and PostgreSQL

---

## Troubleshooting

### Containers won't start

```bash
# Check if ports are in use
lsof -i :3306
lsof -i :5432
lsof -i :8080

# Change ports in docker-compose.yml or .env if needed
```

### Can't connect to database

```bash
# Check container health
docker compose ps

# View container logs
docker compose logs postgres
docker compose logs mysql
```

### Reset everything

```bash
# Stop and remove containers + volumes
docker compose down -v

# Remove any cached data
rm -rf mysql_data postgres_data

# Start fresh
docker compose up -d
```

---

## What's Next?

After completing these lessons:

1. **Data Modeling** - Learn about dimensional modeling, star schemas
2. **ETL/ELT** - Build data pipelines with Python + SQL
3. **Performance Tuning** - Deep dive into query optimization
4. **Cloud Databases** - AWS RDS, Google Cloud SQL, Azure SQL

---

## License

Educational use only. Created for learning SQL fundamentals.
