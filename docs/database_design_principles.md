# Database Design Principles

## 1. Entity-Relationship (ER) Modeling

### What is ER Modeling?
Entity-Relationship modeling is a conceptual approach to database design that identifies:
- **Entities**: Things or objects (e.g., Books, Authors, Members)
- **Attributes**: Properties of entities (e.g., Book title, Author name)
- **Relationships**: How entities are related (e.g., Authors write Books)

### Example: Library System ER Model
```
Authors (1) ----writes----> (M) Books (M) ----borrowed_by----> (M) Members
   |                           |                                   |
   |                           |                                   |
author_id                   book_id                           member_id
first_name                  title                            first_name
last_name                   isbn                             last_name
birth_date                  price                            email
nationality                 pages                            join_date
```

### Relationship Types
- **One-to-One (1:1)**: Each entity instance relates to exactly one instance of another entity
- **One-to-Many (1:M)**: One entity instance relates to many instances of another entity
- **Many-to-Many (M:M)**: Many instances of one entity relate to many instances of another entity

## 2. Database Normalization

Normalization is the process of organizing data to reduce redundancy and improve data integrity.

### First Normal Form (1NF)
- Each table cell contains a single value
- Each column has a unique name
- Each row is unique

**Before 1NF (Bad):**
| Book_ID | Title | Authors |
|---------|-------|---------|
| 1 | Good Omens | Terry Pratchett, Neil Gaiman |

**After 1NF (Good):**
| Book_ID | Title | Author_ID | Author_Name |
|---------|-------|-----------|-------------|
| 1 | Good Omens | 1 | Terry Pratchett |
| 1 | Good Omens | 2 | Neil Gaiman |

### Second Normal Form (2NF)
- Meets 1NF requirements
- All non-key attributes are fully functionally dependent on the primary key
- Eliminates partial dependencies

**Before 2NF (Bad):**
| Order_ID | Product_ID | Product_Name | Quantity | Product_Price |
|----------|------------|--------------|----------|---------------|
| 1 | 101 | Book A | 2 | 15.99 |

**After 2NF (Good):**
Orders Table:
| Order_ID | Product_ID | Quantity |
|----------|------------|----------|
| 1 | 101 | 2 |

Products Table:
| Product_ID | Product_Name | Price |
|------------|--------------|-------|
| 101 | Book A | 15.99 |

### Third Normal Form (3NF)
- Meets 2NF requirements
- No transitive dependencies (non-key attributes don't depend on other non-key attributes)

**Before 3NF (Bad):**
| Student_ID | Student_Name | Course_ID | Course_Name | Instructor_Name |
|------------|--------------|-----------|-------------|-----------------|
| 1 | John | CS101 | Intro to Programming | Dr. Smith |

**After 3NF (Good):**
Students Table:
| Student_ID | Student_Name |
|------------|--------------|
| 1 | John |

Enrollments Table:
| Student_ID | Course_ID |
|------------|-----------|
| 1 | CS101 |

Courses Table:
| Course_ID | Course_Name | Instructor_Name |
|-----------|-------------|-----------------|
| CS101 | Intro to Programming | Dr. Smith |

## 3. Primary Keys and Foreign Keys

### Primary Keys
- Uniquely identifies each row in a table
- Cannot be NULL
- Should be stable (not change frequently)
- Can be single column or composite

```sql
-- Single column primary key
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

-- Composite primary key
CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    role VARCHAR(50),
    PRIMARY KEY (book_id, author_id)
);
```

### Foreign Keys
- References the primary key of another table
- Ensures referential integrity
- Can be NULL (unless specified otherwise)

```sql
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    category_id INTEGER REFERENCES categories(category_id)
);
```

## 4. Data Types and Constraints

### Common Data Types
```sql
-- Numeric types
INTEGER, BIGINT, DECIMAL(10,2), NUMERIC, SERIAL

-- Text types  
VARCHAR(255), TEXT, CHAR(10)

-- Date/Time types
DATE, TIME, TIMESTAMP, INTERVAL

-- Boolean
BOOLEAN

-- JSON (PostgreSQL)
JSON, JSONB
```

### Constraints
```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2) CHECK (price >= 0),
    category_id INTEGER REFERENCES categories(category_id),
    sku VARCHAR(50) UNIQUE NOT NULL,
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Types of Constraints:
- **NOT NULL**: Column cannot be empty
- **UNIQUE**: Values must be unique across the table
- **CHECK**: Values must satisfy a condition
- **DEFAULT**: Provides a default value
- **FOREIGN KEY**: Maintains referential integrity

## 5. Indexing Strategy

### When to Create Indexes
- Columns used frequently in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY
- Foreign key columns

### Types of Indexes
```sql
-- B-tree index (default)
CREATE INDEX idx_books_title ON books(title);

-- Composite index
CREATE INDEX idx_loans_member_date ON loans(member_id, loan_date);

-- Unique index
CREATE UNIQUE INDEX idx_books_isbn ON books(isbn);

-- Partial index
CREATE INDEX idx_active_loans ON loans(member_id) WHERE status = 'active';
```

### Index Best Practices
- Don't over-index (slows down INSERT/UPDATE/DELETE)
- Monitor index usage with database tools
- Consider composite indexes for multi-column queries
- Regular maintenance (REINDEX, ANALYZE)

## 6. Database Design Patterns

### Junction Tables (Many-to-Many)
```sql
-- Authors and Books have a many-to-many relationship
CREATE TABLE book_authors (
    book_id INTEGER REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INTEGER REFERENCES authors(author_id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'author',
    PRIMARY KEY (book_id, author_id)
);
```

### Lookup Tables
```sql
-- Small, relatively static reference data
CREATE TABLE statuses (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

INSERT INTO statuses (status_name, description) VALUES
('active', 'Currently active'),
('inactive', 'Temporarily inactive'),
('suspended', 'Account suspended');
```

### Audit Tables
```sql
-- Track changes to important data
CREATE TABLE book_audit (
    audit_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    action VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_by INTEGER REFERENCES users(user_id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 7. Common Design Mistakes to Avoid

### 1. Storing Multiple Values in One Column
**Bad:**
```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    product_ids VARCHAR(255) -- '1,2,3,4'
);
```

**Good:**
```sql
CREATE TABLE order_items (
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL
);
```

### 2. Not Using Foreign Keys
**Bad:**
```sql
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    category_id INTEGER -- No foreign key constraint
);
```

**Good:**
```sql
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(category_id)
);
```

### 3. Overly Generic Table Design
**Bad:**
```sql
CREATE TABLE entity_attribute_value (
    entity_id INTEGER,
    attribute_name VARCHAR(100),
    attribute_value TEXT
);
```

**Good:**
```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2),
    description TEXT
);
```

## 8. Performance Considerations

### Query Performance Tips
- Use appropriate indexes
- Avoid SELECT *
- Use LIMIT for large result sets
- Consider query execution plans (EXPLAIN)
- Normalize appropriately (sometimes denormalization helps)

### Database Maintenance
- Regular VACUUM and ANALYZE (PostgreSQL)
- Monitor query performance
- Archive old data
- Keep statistics up to date

## Practice Exercise

Design a database schema for a simple e-learning platform with the following requirements:
- Students can enroll in multiple courses
- Courses have multiple lessons
- Students can complete lessons and receive grades
- Instructors can teach multiple courses
- Courses belong to categories

Try to identify:
1. All entities and their attributes
2. Relationships between entities
3. Primary and foreign keys
4. Necessary constraints and indexes
5. Sample queries you might need to run

Compare your design with the e-commerce schema in `schemas/02_ecommerce_system.sql` for ideas and patterns!