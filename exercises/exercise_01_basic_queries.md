# Exercise 1: Basic SQL Queries

## Setup
Make sure you have loaded the library system schema (`schemas/01_library_system.sql`) before starting these exercises.

## Exercises

### 1.1 Simple SELECT Queries
**Task**: Write queries to answer the following questions:

1. List all authors in the database.
2. Show only the titles and publication years of all books.
3. Find all books published after 2010.
4. List all members who joined in 2023.

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. List all authors
SELECT * FROM authors;

-- 2. Show titles and publication years
SELECT title, publication_year FROM books;

-- 3. Books published after 2010
SELECT title, publication_year 
FROM books 
WHERE publication_year > 2010;

-- 4. Members who joined in 2023
SELECT first_name, last_name, join_date 
FROM members 
WHERE EXTRACT(YEAR FROM join_date) = 2023;
```
</details>

### 1.2 Filtering and Sorting
**Task**: Create queries for these requirements:

1. Find all books with more than 300 pages, ordered by page count.
2. List premium members in alphabetical order by last name.
3. Show books with prices between $15 and $30.
4. Find all authors whose nationality contains "British" or "American".

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Books with more than 300 pages
SELECT title, pages 
FROM books 
WHERE pages > 300 
ORDER BY pages DESC;

-- 2. Premium members alphabetically
SELECT first_name, last_name, membership_type 
FROM members 
WHERE membership_type = 'premium' 
ORDER BY last_name ASC;

-- 3. Books priced between $15 and $30
SELECT title, price 
FROM books 
WHERE price BETWEEN 15.00 AND 30.00;

-- 4. British or American authors
SELECT first_name, last_name, nationality 
FROM authors 
WHERE nationality LIKE '%British%' OR nationality LIKE '%American%';
```
</details>

### 1.3 Aggregate Functions
**Task**: Answer these questions using aggregate functions:

1. How many books are in the library?
2. What is the average price of all books?
3. What is the total value of inventory (sum of price × stock_quantity)?
4. How many different publishers are there?

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Total number of books
SELECT COUNT(*) as total_books FROM books;

-- 2. Average book price
SELECT AVG(price) as average_price FROM books;

-- 3. Total inventory value
SELECT SUM(price * stock_quantity) as total_inventory_value FROM books;

-- 4. Number of different publishers
SELECT COUNT(DISTINCT publisher_id) as publisher_count FROM books;
```
</details>

### 1.4 GROUP BY and HAVING
**Task**: Create queries to find:

1. Number of books in each category.
2. Categories that have more than 2 books.
3. Average book price by publisher.
4. Members with more than 3 active loans.

<details>
<summary>Click here for solutions</summary>

```sql
-- 1. Books per category
SELECT c.name, COUNT(b.book_id) as book_count
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name;

-- 2. Categories with more than 2 books
SELECT c.name, COUNT(b.book_id) as book_count
FROM categories c
JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(b.book_id) > 2;

-- 3. Average price by publisher
SELECT p.name, AVG(b.price) as avg_price
FROM publishers p
JOIN books b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_id, p.name;

-- 4. Members with more than 3 active loans
SELECT m.first_name, m.last_name, COUNT(l.loan_id) as active_loans
FROM members m
JOIN loans l ON m.member_id = l.member_id
WHERE l.status = 'active'
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(l.loan_id) > 3;
```
</details>

## Challenge Questions

### Challenge 1: Complex Filtering
Find all books that:
- Are priced above the average price of books in their category
- Have more than 5 copies in stock
- Were published in the last 10 years

### Challenge 2: Data Analysis
Create a report showing:
- Category name
- Number of books in category  
- Average price in category
- Most expensive book title in category
- Total inventory value for category

Try to solve these challenges on your own first, then check the solutions in the `solutions/` folder!