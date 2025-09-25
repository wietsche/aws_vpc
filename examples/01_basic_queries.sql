-- Basic SQL Queries Examples
-- This file demonstrates fundamental SQL operations

-- ===========================================
-- SELECT QUERIES
-- ===========================================

-- 1. Simple SELECT with all columns
SELECT * FROM authors;

-- 2. SELECT specific columns
SELECT first_name, last_name, nationality FROM authors;

-- 3. SELECT with WHERE clause
SELECT title, publication_year 
FROM books 
WHERE publication_year > 2000;

-- 4. SELECT with multiple conditions
SELECT title, price 
FROM books 
WHERE price BETWEEN 10.00 AND 50.00 
AND stock_quantity > 0;

-- 5. SELECT with LIKE pattern matching
SELECT first_name, last_name 
FROM authors 
WHERE last_name LIKE 'R%';

-- 6. SELECT with IN clause
SELECT title, category_id 
FROM books 
WHERE category_id IN (1, 2, 3);

-- 7. SELECT with ORDER BY
SELECT title, price 
FROM books 
ORDER BY price DESC, title ASC;

-- 8. SELECT with LIMIT
SELECT title, publication_year 
FROM books 
ORDER BY publication_year DESC 
LIMIT 5;

-- ===========================================
-- AGGREGATE FUNCTIONS
-- ===========================================

-- 9. COUNT records
SELECT COUNT(*) as total_books FROM books;

-- 10. COUNT with condition
SELECT COUNT(*) as books_in_stock 
FROM books 
WHERE stock_quantity > 0;

-- 11. SUM function
SELECT SUM(stock_quantity) as total_inventory 
FROM books;

-- 12. AVG function
SELECT AVG(price) as average_price 
FROM books 
WHERE price IS NOT NULL;

-- 13. MIN and MAX
SELECT 
    MIN(price) as cheapest_book,
    MAX(price) as most_expensive_book
FROM books;

-- ===========================================
-- GROUP BY and HAVING
-- ===========================================

-- 14. GROUP BY with COUNT
SELECT category_id, COUNT(*) as book_count 
FROM books 
GROUP BY category_id;

-- 15. GROUP BY with multiple aggregates
SELECT 
    category_id,
    COUNT(*) as book_count,
    AVG(price) as avg_price,
    SUM(stock_quantity) as total_stock
FROM books 
GROUP BY category_id;

-- 16. GROUP BY with HAVING
SELECT category_id, COUNT(*) as book_count 
FROM books 
GROUP BY category_id 
HAVING COUNT(*) > 2;

-- ===========================================
-- SUBQUERIES
-- ===========================================

-- 17. Subquery in WHERE clause
SELECT title, price 
FROM books 
WHERE price > (SELECT AVG(price) FROM books);

-- 18. Subquery with EXISTS
SELECT first_name, last_name 
FROM authors a 
WHERE EXISTS (
    SELECT 1 FROM book_authors ba 
    WHERE ba.author_id = a.author_id
);

-- 19. Subquery in SELECT clause
SELECT 
    title,
    price,
    (SELECT AVG(price) FROM books) as avg_price,
    price - (SELECT AVG(price) FROM books) as price_difference
FROM books;