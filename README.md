# Learning Relational Databases

This repository contains practical examples and exercises for learning relational database concepts, SQL queries, and database design principles.

## What You'll Learn

- **Database Design**: Entity-Relationship modeling, normalization, and schema design
- **SQL Fundamentals**: SELECT, INSERT, UPDATE, DELETE operations
- **Advanced SQL**: JOINs, subqueries, window functions, and complex queries
- **Database Constraints**: Primary keys, foreign keys, unique constraints, and check constraints
- **Indexing**: Understanding and implementing database indexes for performance
- **Transactions**: ACID properties and transaction management
- **Views and Stored Procedures**: Creating reusable database objects

# Learning Relational Databases

This repository contains practical examples and exercises for learning relational database concepts, SQL queries, and database design principles.

## 🚀 Quick Start

**New to databases?** Start here: [Getting Started Guide](docs/getting_started.md)

1. **Prerequisites**: Docker installed
2. **Setup**: `docker compose up -d`
3. **Connect**: Open http://localhost:8080 (Adminer web interface)
4. **Learn**: Follow the exercises in order

## 📚 What You'll Learn

- **Database Design**: Entity-Relationship modeling, normalization, and schema design
- **SQL Fundamentals**: SELECT, INSERT, UPDATE, DELETE operations
- **Advanced SQL**: JOINs, subqueries, window functions, and complex queries
- **Database Constraints**: Primary keys, foreign keys, unique constraints, and check constraints
- **Indexing**: Understanding and implementing database indexes for performance
- **Transactions**: ACID properties and transaction management
- **Views and Stored Procedures**: Creating reusable database objects

## 📁 Repository Structure

```
├── docs/                   # Documentation and guides
│   ├── getting_started.md     # Quick start guide
│   └── database_design_principles.md # Design theory
├── schemas/                # Database schema definitions
│   ├── 01_library_system.sql    # Library management schema
│   └── 02_ecommerce_system.sql  # E-commerce schema
├── examples/               # SQL example queries by topic
│   ├── 01_basic_queries.sql     # SELECT, WHERE, GROUP BY
│   ├── 02_joins.sql            # All types of JOINs
│   └── 03_advanced_queries.sql  # Window functions, CTEs
├── exercises/              # Hands-on exercises with solutions
│   ├── exercise_01_basic_queries.md
│   └── exercise_02_joins.md
├── data/                   # Sample datasets for practice
│   └── sample_data.sql        # Test data for schemas
└── docker-compose.yml      # Database setup with Docker
```

## 🎯 Learning Path

### 👶 Beginner Track
1. **Start Here**: [Getting Started Guide](docs/getting_started.md)
2. **Theory**: [Database Design Principles](docs/database_design_principles.md)
3. **Practice**: [Basic SQL Queries](exercises/exercise_01_basic_queries.md)
4. **Practice**: [JOIN Operations](exercises/exercise_02_joins.md)

### 🚀 Intermediate Track
1. **Study**: Advanced query examples (`examples/03_advanced_queries.sql`)
2. **Analyze**: Compare the two schema designs
3. **Build**: Create your own schema for a different domain
4. **Optimize**: Learn about indexing and query performance

### 🏆 Advanced Track
1. **Design**: Complex multi-table relationships
2. **Performance**: Query optimization and execution plans  
3. **Scale**: Partitioning and large dataset strategies
4. **Project**: Build a complete application database

## 🗄️ Supported Databases

This repository includes examples for:
- **PostgreSQL** (primary focus) - Advanced features and standards compliance
- **MySQL** - Popular web development database
- **SQLite** - Lightweight local testing (examples work with minor syntax changes)

Each database has its own Docker configuration and specific examples highlighting unique features.

## 🛠️ Prerequisites

- **Docker** installed on your local machine
- **SQL client** (Adminer included, or use DBeaver, pgAdmin, VS Code, etc.)
- **Basic understanding** of data and tables (helpful but not required)

## ⚡ Quick Commands

```bash
# Start databases
docker compose up -d

# Load library schema and data
docker exec -i learning_postgres psql -U student -d learning_db < schemas/01_library_system.sql
docker exec -i learning_postgres psql -U student -d learning_db < data/sample_data.sql

# Access PostgreSQL command line
docker exec -it learning_postgres psql -U student -d learning_db

# Stop databases
docker compose down
```

## 🎮 Try It Now!

After starting the Docker containers, run this query in Adminer (http://localhost:8080):

```sql
-- Find the most popular books by loan count
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name AS author,
    COUNT(l.loan_id) AS times_borrowed
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id  
JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title, a.first_name, a.last_name
ORDER BY times_borrowed DESC, b.title
LIMIT 5;
```

## 🤝 Contributing

Found an error or have a suggestion? Please open an issue or submit a pull request!

## 📄 License

This educational content is available for free use and modification. See individual files for any specific attributions.

---

**Happy Learning!** 🎓 Start with the [Getting Started Guide](docs/getting_started.md) and work through the exercises at your own pace.
