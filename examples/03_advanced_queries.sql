-- Advanced SQL Concepts
-- Window Functions, CTEs, and Complex Queries

-- ===========================================
-- WINDOW FUNCTIONS
-- ===========================================

-- 1. ROW_NUMBER() - Assign sequential numbers
SELECT 
    title,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) as price_rank
FROM books
WHERE price IS NOT NULL;

-- 2. RANK() and DENSE_RANK() - Handle ties differently
SELECT 
    title,
    price,
    RANK() OVER (ORDER BY price DESC) as price_rank,
    DENSE_RANK() OVER (ORDER BY price DESC) as dense_price_rank
FROM books
WHERE price IS NOT NULL;

-- 3. PARTITION BY with window functions
SELECT 
    b.title,
    c.name as category,
    b.price,
    ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY b.price DESC) as category_price_rank,
    AVG(b.price) OVER (PARTITION BY c.category_id) as avg_category_price
FROM books b
JOIN categories c ON b.category_id = c.category_id
WHERE b.price IS NOT NULL;

-- 4. LAG() and LEAD() - Access previous/next rows
SELECT 
    title,
    publication_year,
    price,
    LAG(price, 1) OVER (ORDER BY publication_year) as previous_year_price,
    LEAD(price, 1) OVER (ORDER BY publication_year) as next_year_price,
    price - LAG(price, 1) OVER (ORDER BY publication_year) as price_change
FROM books
WHERE price IS NOT NULL
ORDER BY publication_year;

-- 5. FIRST_VALUE() and LAST_VALUE()
SELECT 
    title,
    price,
    FIRST_VALUE(title) OVER (ORDER BY price ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as cheapest_book,
    LAST_VALUE(title) OVER (ORDER BY price ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as most_expensive_book
FROM books
WHERE price IS NOT NULL;

-- 6. Running totals with SUM() OVER()
SELECT 
    l.loan_date,
    l.fine_amount,
    SUM(l.fine_amount) OVER (ORDER BY l.loan_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total_fines
FROM loans l
WHERE l.fine_amount > 0
ORDER BY l.loan_date;

-- ===========================================
-- COMMON TABLE EXPRESSIONS (CTEs)
-- ===========================================

-- 7. Simple CTE
WITH expensive_books AS (
    SELECT book_id, title, price
    FROM books
    WHERE price > 15.00
)
SELECT eb.title, eb.price, COUNT(l.loan_id) as loan_count
FROM expensive_books eb
LEFT JOIN loans l ON eb.book_id = l.book_id
GROUP BY eb.book_id, eb.title, eb.price
ORDER BY loan_count DESC;

-- 8. Multiple CTEs
WITH author_stats AS (
    SELECT 
        a.author_id,
        a.first_name,
        a.last_name,
        COUNT(DISTINCT ba.book_id) as books_written
    FROM authors a
    LEFT JOIN book_authors ba ON a.author_id = ba.author_id
    GROUP BY a.author_id, a.first_name, a.last_name
),
book_popularity AS (
    SELECT 
        b.book_id,
        COUNT(l.loan_id) as times_borrowed
    FROM books b
    LEFT JOIN loans l ON b.book_id = l.book_id
    GROUP BY b.book_id
)
SELECT 
    ast.first_name,
    ast.last_name,
    ast.books_written,
    AVG(bp.times_borrowed) as avg_book_popularity
FROM author_stats ast
JOIN book_authors ba ON ast.author_id = ba.author_id
JOIN book_popularity bp ON ba.book_id = bp.book_id
WHERE ast.books_written > 0
GROUP BY ast.author_id, ast.first_name, ast.last_name, ast.books_written
ORDER BY avg_book_popularity DESC;

-- 9. Recursive CTE (for hierarchical data)
-- Assuming we have hierarchical categories
WITH RECURSIVE category_hierarchy AS (
    -- Base case: root categories
    SELECT 
        category_id,
        name,
        parent_category_id,
        0 as level,
        name as path
    FROM categories
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- Recursive case: child categories
    SELECT 
        c.category_id,
        c.name,
        c.parent_category_id,
        ch.level + 1,
        ch.path || ' -> ' || c.name
    FROM categories c
    JOIN category_hierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT level, path, name
FROM category_hierarchy
ORDER BY level, path;

-- ===========================================
-- ADVANCED SUBQUERIES AND EXISTS
-- ===========================================

-- 10. Correlated subquery
SELECT 
    b.title,
    b.price,
    (SELECT COUNT(*) 
     FROM books b2 
     WHERE b2.category_id = b.category_id 
     AND b2.price < b.price) as cheaper_books_in_category
FROM books b
WHERE b.price IS NOT NULL
ORDER BY b.category_id, b.price;

-- 11. EXISTS with complex conditions
SELECT 
    a.first_name,
    a.last_name
FROM authors a
WHERE EXISTS (
    SELECT 1
    FROM book_authors ba
    JOIN books b ON ba.book_id = b.book_id
    JOIN loans l ON b.book_id = l.book_id
    WHERE ba.author_id = a.author_id
    GROUP BY ba.author_id
    HAVING COUNT(DISTINCT l.member_id) > 3  -- Authors whose books were borrowed by more than 3 different members
);

-- 12. NOT EXISTS
SELECT 
    b.title,
    b.isbn
FROM books b
WHERE NOT EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.book_id = b.book_id
    AND l.status = 'overdue'
); -- Books that have never been overdue

-- ===========================================
-- CASE STATEMENTS AND CONDITIONAL LOGIC
-- ===========================================

-- 13. Complex CASE statement
SELECT 
    m.first_name,
    m.last_name,
    m.membership_type,
    COUNT(l.loan_id) as total_loans,
    SUM(l.fine_amount) as total_fines,
    CASE 
        WHEN COUNT(l.loan_id) = 0 THEN 'No Activity'
        WHEN COUNT(l.loan_id) <= 5 THEN 'Light Reader'
        WHEN COUNT(l.loan_id) <= 15 THEN 'Regular Reader'
        WHEN COUNT(l.loan_id) <= 30 THEN 'Heavy Reader'
        ELSE 'Bookworm'
    END as reader_category,
    CASE 
        WHEN SUM(l.fine_amount) = 0 THEN 'Perfect Record'
        WHEN SUM(l.fine_amount) <= 5.00 THEN 'Occasional Late'
        WHEN SUM(l.fine_amount) <= 20.00 THEN 'Frequently Late'
        ELSE 'Chronic Offender'
    END as payment_behavior
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
ORDER BY total_loans DESC;

-- ===========================================
-- PIVOT-LIKE OPERATIONS
-- ===========================================

-- 14. Manual pivot using CASE and GROUP BY
SELECT 
    p.name as publisher,
    SUM(CASE WHEN c.name = 'Fiction' THEN 1 ELSE 0 END) as fiction_books,
    SUM(CASE WHEN c.name = 'Classic Literature' THEN 1 ELSE 0 END) as classic_books,
    SUM(CASE WHEN c.name = 'Fantasy' THEN 1 ELSE 0 END) as fantasy_books,
    SUM(CASE WHEN c.name = 'Dystopian' THEN 1 ELSE 0 END) as dystopian_books
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
LEFT JOIN categories c ON b.category_id = c.category_id
GROUP BY p.publisher_id, p.name
ORDER BY p.name;

-- ===========================================
-- PERFORMANCE ANALYSIS QUERIES
-- ===========================================

-- 15. Loan performance by month
SELECT 
    DATE_TRUNC('month', l.loan_date) as loan_month,
    COUNT(*) as loans_issued,
    COUNT(CASE WHEN l.return_date IS NOT NULL THEN 1 END) as loans_returned,
    COUNT(CASE WHEN l.status = 'overdue' THEN 1 END) as loans_overdue,
    SUM(l.fine_amount) as total_fines,
    ROUND(
        COUNT(CASE WHEN l.return_date IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as return_percentage
FROM loans l
GROUP BY DATE_TRUNC('month', l.loan_date)
ORDER BY loan_month;

-- 16. Author popularity trend
WITH monthly_borrows AS (
    SELECT 
        a.author_id,
        a.first_name || ' ' || a.last_name as author_name,
        DATE_TRUNC('month', l.loan_date) as loan_month,
        COUNT(l.loan_id) as monthly_loans
    FROM authors a
    JOIN book_authors ba ON a.author_id = ba.author_id
    JOIN books b ON ba.book_id = b.book_id
    JOIN loans l ON b.book_id = l.book_id
    GROUP BY a.author_id, author_name, DATE_TRUNC('month', l.loan_date)
)
SELECT 
    author_name,
    loan_month,
    monthly_loans,
    LAG(monthly_loans, 1) OVER (PARTITION BY author_id ORDER BY loan_month) as prev_month_loans,
    monthly_loans - LAG(monthly_loans, 1) OVER (PARTITION BY author_id ORDER BY loan_month) as loan_change
FROM monthly_borrows
ORDER BY author_name, loan_month;