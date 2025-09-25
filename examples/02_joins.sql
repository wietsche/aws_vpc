-- JOIN Operations Examples
-- This file demonstrates different types of JOIN operations

-- ===========================================
-- INNER JOIN
-- ===========================================

-- 1. Simple INNER JOIN
SELECT 
    b.title,
    c.name as category_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id;

-- 2. INNER JOIN with multiple tables
SELECT 
    b.title,
    c.name as category,
    p.name as publisher
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id;

-- 3. INNER JOIN with WHERE clause
SELECT 
    b.title,
    a.first_name,
    a.last_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
WHERE b.publication_year > 2000;

-- ===========================================
-- LEFT JOIN (LEFT OUTER JOIN)
-- ===========================================

-- 4. LEFT JOIN to show all authors (even those without books)
SELECT 
    a.first_name,
    a.last_name,
    COUNT(ba.book_id) as book_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
GROUP BY a.author_id, a.first_name, a.last_name
ORDER BY book_count DESC;

-- 5. LEFT JOIN to find authors without books
SELECT 
    a.first_name,
    a.last_name
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
WHERE ba.author_id IS NULL;

-- ===========================================
-- RIGHT JOIN (RIGHT OUTER JOIN)
-- ===========================================

-- 6. RIGHT JOIN example
SELECT 
    b.title,
    c.name as category_name
FROM books b
RIGHT JOIN categories c ON b.category_id = c.category_id;

-- ===========================================
-- FULL OUTER JOIN
-- ===========================================

-- 7. FULL OUTER JOIN (PostgreSQL syntax)
SELECT 
    a.first_name,
    a.last_name,
    b.title
FROM authors a
FULL OUTER JOIN book_authors ba ON a.author_id = ba.author_id
FULL OUTER JOIN books b ON ba.book_id = b.book_id;

-- ===========================================
-- SELF JOIN
-- ===========================================

-- 8. Self JOIN for hierarchical data (using categories with parent_category_id)
-- First, let's add some hierarchical data to categories
-- This would be run as separate statements:
/*
INSERT INTO categories (name, description, parent_category_id) VALUES
('Science Fiction', 'Futuristic and speculative fiction', 1),
('Mystery', 'Crime and detective stories', 1);
*/

-- Self JOIN to show category hierarchy
SELECT 
    child.name as subcategory,
    parent.name as parent_category
FROM categories child
LEFT JOIN categories parent ON child.parent_category_id = parent.category_id
WHERE child.parent_category_id IS NOT NULL;

-- ===========================================
-- CROSS JOIN
-- ===========================================

-- 9. CROSS JOIN (Cartesian product - use with caution!)
-- This creates every possible combination
SELECT 
    a.first_name + ' ' + a.last_name as author_name,
    c.name as category_name
FROM authors a
CROSS JOIN categories c
LIMIT 10; -- Limiting results for safety

-- ===========================================
-- COMPLEX JOIN EXAMPLES
-- ===========================================

-- 10. Multiple JOINs with aggregation
SELECT 
    a.first_name,
    a.last_name,
    COUNT(DISTINCT b.book_id) as books_written,
    AVG(b.price) as avg_book_price,
    SUM(b.stock_quantity) as total_copies_in_stock
FROM authors a
JOIN book_authors ba ON a.author_id = ba.author_id
JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.first_name, a.last_name
HAVING COUNT(DISTINCT b.book_id) > 0
ORDER BY books_written DESC;

-- 11. JOIN with subquery
SELECT 
    b.title,
    b.price,
    avg_price_by_category.avg_price as category_avg_price
FROM books b
JOIN (
    SELECT 
        category_id,
        AVG(price) as avg_price
    FROM books
    GROUP BY category_id
) avg_price_by_category ON b.category_id = avg_price_by_category.category_id
WHERE b.price > avg_price_by_category.avg_price;

-- 12. Complex library scenario - find overdue loans
SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.loan_date,
    l.due_date,
    CURRENT_DATE - l.due_date as days_overdue
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL 
AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;