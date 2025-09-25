# Exercise 2: JOIN Operations

## Setup
Ensure you have loaded both the library system schema and have some sample data loaded.

## Exercises

### 2.1 Basic INNER JOINs
**Task**: Write queries using INNER JOIN:

1. List all books with their category names.
2. Show all books with their publisher information.
3. Display book titles with their authors' names.
4. Find all active loans with member names and book titles.

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Books with category names
SELECT b.title, c.name as category_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id;

-- 2. Books with publisher information  
SELECT b.title, p.name as publisher_name, p.founded_year
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.publisher_id;

-- 3. Books with authors
SELECT b.title, a.first_name, a.last_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;

-- 4. Active loans with names
SELECT 
    m.first_name || ' ' || m.last_name as member_name,
    b.title,
    l.loan_date,
    l.due_date
FROM loans l
INNER JOIN members m ON l.member_id = m.member_id  
INNER JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'active';
```
</details>

### 2.2 LEFT JOINs
**Task**: Use LEFT JOIN for these scenarios:

1. Show all authors and the number of books they've written (include authors with 0 books).
2. List all categories and count of books in each (include empty categories).
3. Find all members and their total loan count (include members who never borrowed).
4. Show all publishers and their newest publication year (include publishers with no books).

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. All authors with book counts
SELECT 
    a.first_name,
    a.last_name,
    COUNT(ba.book_id) as book_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
GROUP BY a.author_id, a.first_name, a.last_name
ORDER BY book_count DESC;

-- 2. All categories with book counts
SELECT 
    c.name,
    COUNT(b.book_id) as book_count
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
ORDER BY book_count DESC;

-- 3. All members with loan counts
SELECT 
    m.first_name,
    m.last_name,
    COUNT(l.loan_id) as total_loans
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY total_loans DESC;

-- 4. Publishers with newest publication year
SELECT 
    p.name,
    MAX(b.publication_year) as newest_publication
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_id, p.name;
```
</details>

### 2.3 Multiple JOINs
**Task**: Create complex queries with multiple JOINs:

1. Show book title, author name, category, and publisher for all books.
2. List member name, book title, category, and loan status for all loans.
3. Find overdue loans with all relevant information (member, book, author, days overdue).

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Complete book information
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name as author_name,
    c.name as category,
    p.name as publisher
FROM books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN categories c ON b.category_id = c.category_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
ORDER BY b.title;

-- 2. Complete loan information
SELECT 
    m.first_name || ' ' || m.last_name as member_name,
    b.title,
    c.name as category,
    l.status,
    l.loan_date,
    l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
JOIN categories c ON b.category_id = c.category_id
ORDER BY l.loan_date DESC;

-- 3. Overdue loans with full details
SELECT 
    m.first_name || ' ' || m.last_name as member_name,
    m.email,
    b.title,
    a.first_name || ' ' || a.last_name as author_name,
    l.loan_date,
    l.due_date,
    CURRENT_DATE - l.due_date as days_overdue,
    CASE 
        WHEN CURRENT_DATE - l.due_date <= 7 THEN l.fine_amount * 1.0
        WHEN CURRENT_DATE - l.due_date <= 14 THEN l.fine_amount * 1.5  
        ELSE l.fine_amount * 2.0
    END as calculated_fine
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
WHERE l.return_date IS NULL 
AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;
```
</details>

### 2.4 Advanced JOIN Scenarios
**Task**: Solve these challenging JOIN problems:

1. Find books that have never been borrowed.
2. List authors who have written books in multiple categories.
3. Show members who have borrowed books from all available categories.
4. Find the most popular book (most borrowed) in each category.

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Books never borrowed
SELECT b.title, b.isbn
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
WHERE l.book_id IS NULL;

-- 2. Authors with books in multiple categories
SELECT 
    a.first_name,
    a.last_name,
    COUNT(DISTINCT c.category_id) as categories_count,
    STRING_AGG(DISTINCT c.name, ', ') as categories
FROM authors a
JOIN book_authors ba ON a.author_id = ba.author_id
JOIN books b ON ba.book_id = b.book_id
JOIN categories c ON b.category_id = c.category_id
GROUP BY a.author_id, a.first_name, a.last_name
HAVING COUNT(DISTINCT c.category_id) > 1;

-- 3. Members who borrowed from all categories
SELECT 
    m.first_name,
    m.last_name,
    COUNT(DISTINCT c.category_id) as categories_borrowed_from
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN books b ON l.book_id = b.book_id
JOIN categories c ON b.category_id = c.category_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(DISTINCT c.category_id) = (SELECT COUNT(*) FROM categories);

-- 4. Most popular book per category
WITH book_popularity AS (
    SELECT 
        b.book_id,
        b.title,
        c.name as category,
        COUNT(l.loan_id) as loan_count,
        ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY COUNT(l.loan_id) DESC) as rn
    FROM books b
    JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN loans l ON b.book_id = l.book_id
    GROUP BY b.book_id, b.title, c.category_id, c.name
)
SELECT category, title, loan_count
FROM book_popularity
WHERE rn = 1
ORDER BY loan_count DESC;
```
</details>

## Challenge Problems

### Challenge 1: Library Analytics
Create a comprehensive library report that shows:
- Most active member (most loans)
- Most popular author (most borrowed books)  
- Category with highest average book price
- Publisher with most books in circulation

### Challenge 2: Revenue Analysis  
Calculate potential revenue by finding:
- Total fine amount collected per month
- Average loan duration by category
- Members who owe the most in fines
- Books that generate the most fine revenue

Work through these challenges and compare your solutions with others!