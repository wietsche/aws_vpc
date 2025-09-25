-- Sample Data for Library Management System
-- Run this after creating the schema to populate with test data

-- Insert more sample data into existing tables

-- Additional books
INSERT INTO books (title, isbn, publisher_id, category_id, publication_year, pages, price, stock_quantity) VALUES
('Harry Potter and the Philosopher''s Stone', '978-0-7475-3269-9', 1, 3, 1997, 223, 15.99, 10),
('1984', '978-0-452-28423-4', 2, 4, 1949, 328, 13.99, 8),
('To Kill a Mockingbird', '978-0-06-112008-4', 2, 2, 1960, 376, 14.99, 5),
('The Great Gatsby', '978-0-7432-7356-5', 3, 2, 1925, 180, 12.99, 12),
('Pride and Prejudice', '978-0-14-143951-8', 1, 2, 1813, 279, 11.99, 7),
('The Catcher in the Rye', '978-0-316-76948-0', 2, 2, 1951, 277, 13.99, 6);

-- Link books to authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'author'),  -- Harry Potter - J.K. Rowling
(2, 2, 'author'),  -- 1984 - George Orwell
(3, 3, 'author'),  -- To Kill a Mockingbird - Harper Lee
(4, 4, 'author');  -- The Great Gatsby - F. Scott Fitzgerald

-- Insert sample members
INSERT INTO members (first_name, last_name, email, phone, address, join_date, membership_type) VALUES
('Alice', 'Johnson', 'alice.johnson@email.com', '555-0201', '123 Main St, Anytown, USA', '2023-01-15', 'premium'),
('Bob', 'Smith', 'bob.smith@email.com', '555-0202', '456 Oak Ave, Somewhere, USA', '2023-02-20', 'standard'),
('Carol', 'Davis', 'carol.davis@email.com', '555-0203', '789 Pine Rd, Elsewhere, USA', '2023-03-10', 'standard'),
('David', 'Wilson', 'david.wilson@email.com', '555-0204', '321 Elm St, Nowhere, USA', '2023-04-05', 'premium'),
('Eva', 'Brown', 'eva.brown@email.com', '555-0205', '654 Maple Dr, Anywhere, USA', '2023-05-18', 'standard'),
('Frank', 'Miller', 'frank.miller@email.com', '555-0206', '987 Cedar Ln, Someplace, USA', '2023-06-22', 'standard'),
('Grace', 'Taylor', 'grace.taylor@email.com', '555-0207', '147 Birch St, Overthere, USA', '2023-07-30', 'premium');

-- Insert sample loans (some active, some returned, some overdue)
INSERT INTO loans (book_id, member_id, loan_date, due_date, return_date, fine_amount, status) VALUES
-- Active loans
(1, 1, '2024-01-01', '2024-01-15', NULL, 0.00, 'active'),
(2, 2, '2024-01-05', '2024-01-19', NULL, 0.00, 'active'),
(3, 3, '2024-01-10', '2024-01-24', NULL, 0.00, 'active'),

-- Returned loans
(4, 4, '2023-12-01', '2023-12-15', '2023-12-14', 0.00, 'returned'),
(5, 5, '2023-12-05', '2023-12-19', '2023-12-20', 0.50, 'returned'),
(6, 6, '2023-12-10', '2023-12-24', '2023-12-23', 0.00, 'returned'),

-- Overdue loans (past due date, not returned)
(1, 7, '2023-11-15', '2023-11-29', NULL, 5.00, 'overdue'),
(2, 1, '2023-11-20', '2023-12-04', NULL, 3.50, 'overdue'),

-- More active loans for analytics
(3, 2, '2024-01-12', '2024-01-26', NULL, 0.00, 'active'),
(4, 3, '2024-01-14', '2024-01-28', NULL, 0.00, 'active');

-- Additional sample data for more complex queries
INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('Agatha', 'Christie', '1890-09-15', 'British'),
('Stephen', 'King', '1947-09-21', 'American'),
('Jane', 'Austen', '1775-12-16', 'British'),
('Mark', 'Twain', '1835-11-30', 'American'),
('Virginia', 'Woolf', '1882-01-25', 'British');

INSERT INTO books (title, isbn, publisher_id, category_id, publication_year, pages, price, stock_quantity) VALUES
('Murder on the Orient Express', '978-0-06-207350-4', 2, 1, 1934, 256, 14.99, 4),
('The Shining', '978-0-307-74365-9', 1, 1, 1977, 447, 16.99, 3),
('Emma', '978-0-14-143958-7', 1, 2, 1815, 474, 12.99, 6),
('The Adventures of Tom Sawyer', '978-0-486-40077-4', 3, 2, 1876, 224, 10.99, 8),
('Mrs. Dalloway', '978-0-15-662870-9', 2, 2, 1925, 194, 13.99, 5);

-- Link new books to authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(7, 5, 'author'),   -- Murder on the Orient Express - Agatha Christie
(8, 6, 'author'),   -- The Shining - Stephen King
(9, 7, 'author'),   -- Emma - Jane Austen
(10, 8, 'author'),  -- Tom Sawyer - Mark Twain
(11, 9, 'author');  -- Mrs. Dalloway - Virginia Woolf

-- Add some books with multiple authors for more complex queries
INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('Terry', 'Pratchett', '1948-04-28', 'British'),
('Neil', 'Gaiman', '1960-11-10', 'British');

INSERT INTO books (title, isbn, publisher_id, category_id, publication_year, pages, price, stock_quantity) VALUES
('Good Omens', '978-0-06-085398-0', 2, 3, 1990, 432, 17.99, 7);

-- Link Good Omens to both authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(12, 10, 'co-author'),  -- Good Omens - Terry Pratchett
(12, 11, 'co-author');  -- Good Omens - Neil Gaiman

-- Add more loans for better analytics
INSERT INTO loans (book_id, member_id, loan_date, due_date, return_date, fine_amount, status) VALUES
(7, 4, '2024-01-08', '2024-01-22', NULL, 0.00, 'active'),
(8, 5, '2024-01-11', '2024-01-25', NULL, 0.00, 'active'),
(9, 6, '2023-12-15', '2023-12-29', '2023-12-28', 0.00, 'returned'),
(10, 7, '2023-12-18', '2024-01-01', '2024-01-02', 0.25, 'returned'),
(11, 1, '2024-01-06', '2024-01-20', NULL, 0.00, 'active'),
(12, 2, '2024-01-09', '2024-01-23', NULL, 0.00, 'active');