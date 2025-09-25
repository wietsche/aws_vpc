# Getting Started with Relational Database Learning

## Quick Start Guide

### 1. Prerequisites Check
Before you begin, ensure you have:
- [Docker](https://docs.docker.com/get-docker/) installed and running
- A SQL client tool (recommended options below)
- Git (to clone this repository)

### 2. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd aws_vpc

# Start the database services
docker compose up -d

# Wait for databases to initialize (about 30 seconds)
docker compose logs postgres
docker compose logs mysql
```

### 3. Connect to Databases

#### Option A: Using Adminer (Web Interface)
1. Open your browser to http://localhost:8080
2. Choose your database system:
   - **PostgreSQL**: Server: `postgres`, Username: `student`, Password: `learning123`, Database: `learning_db`
   - **MySQL**: Server: `mysql`, Username: `student`, Password: `learning123`, Database: `learning_db`

#### Option B: Using Command Line
```bash
# PostgreSQL
docker exec -it learning_postgres psql -U student -d learning_db

# MySQL  
docker exec -it learning_mysql mysql -u student -p learning_db
# Enter password: learning123
```

#### Option C: Using External SQL Clients
**For PostgreSQL:**
- Host: localhost
- Port: 5432
- Database: learning_db
- Username: student
- Password: learning123

**For MySQL:**
- Host: localhost
- Port: 3306
- Database: learning_db
- Username: student
- Password: learning123

### 4. Load Sample Data
```bash
# Load the library schema and sample data
docker exec -i learning_postgres psql -U student -d learning_db < schemas/01_library_system.sql
docker exec -i learning_postgres psql -U student -d learning_db < data/sample_data.sql
```

### 5. Verify Installation
Run this test query in your SQL client:
```sql
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name AS author_name,
    c.name AS category
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id  
JOIN categories c ON b.category_id = c.category_id
LIMIT 5;
```

If you see book titles with authors and categories, you're ready to go! 🎉

## Learning Path

### Beginner (Start Here)
1. **Database Design Basics**
   - Read: `docs/database_design_principles.md`
   - Practice: Design a simple schema on paper

2. **Basic SQL Queries**
   - Study: `examples/01_basic_queries.sql`
   - Practice: `exercises/exercise_01_basic_queries.md`

3. **Understanding Relationships**
   - Study: `examples/02_joins.sql`
   - Practice: `exercises/exercise_02_joins.md`

### Intermediate  
1. **Advanced SQL Features**
   - Study: `examples/03_advanced_queries.sql`
   - Practice: Create your own window function queries

2. **Schema Design**
   - Analyze: `schemas/01_library_system.sql`
   - Compare: `schemas/02_ecommerce_system.sql`
   - Create: Your own schema for a different domain

### Advanced
1. **Performance Optimization**
   - Learn about query execution plans
   - Practice with large datasets
   - Experiment with indexing strategies

2. **Real-world Projects**
   - Build a complete application database
   - Implement data warehouse concepts
   - Study NoSQL vs SQL trade-offs

## Recommended SQL Clients

### Free Options
- **Adminer** (included in Docker setup) - Web-based, simple
- **DBeaver** - Cross-platform, feature-rich
- **pgAdmin** - PostgreSQL-specific, powerful
- **MySQL Workbench** - MySQL-specific
- **VS Code** - with SQL extensions

### Command Line
- **psql** (PostgreSQL) - included in Docker container
- **mysql** (MySQL) - included in Docker container

## Common Tasks

### Reset Database
```bash
# Stop containers and remove data
docker compose down -v

# Start fresh
docker compose up -d

# Reload data
docker exec -i learning_postgres psql -U student -d learning_db < schemas/01_library_system.sql
docker exec -i learning_postgres psql -U student -d learning_db < data/sample_data.sql
```

### Check Container Status
```bash
# View running containers
docker compose ps

# View logs
docker compose logs postgres
docker compose logs mysql
```

### Backup Data
```bash
# PostgreSQL backup
docker exec learning_postgres pg_dump -U student -d learning_db > backup.sql

# MySQL backup  
docker exec learning_mysql mysqldump -u student -p learning_db > backup.sql
```

## Troubleshooting

### Port Already in Use
If you get port conflicts, edit `docker-compose.yml` and change the port mappings:
```yaml
ports:
  - "5433:5432"  # Change PostgreSQL to port 5433
  - "3307:3306"  # Change MySQL to port 3307
```

### Permission Denied
On Linux/Mac, you might need to run Docker commands with `sudo` or add your user to the docker group.

### Database Connection Fails
- Ensure containers are running: `docker compose ps`
- Check logs: `docker compose logs`
- Wait for databases to fully initialize (30-60 seconds)

## Getting Help

1. Check the issue tracker for common problems
2. Review the documentation in the `docs/` folder
3. Look at example solutions in the exercises
4. Study the sample schemas for patterns

Ready to start learning? Begin with the exercises in the `exercises/` folder! 🚀