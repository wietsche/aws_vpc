-- Library Management System Schema
-- This schema demonstrates key relational database concepts

-- Authors table
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    founded_year INTEGER
);

-- Categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Books table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    category_id INTEGER REFERENCES categories(category_id),
    publication_year INTEGER,
    pages INTEGER CHECK (pages > 0),
    price DECIMAL(10,2) CHECK (price >= 0),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Book Authors junction table (many-to-many relationship)
CREATE TABLE book_authors (
    book_id INTEGER REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INTEGER REFERENCES authors(author_id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'author', -- author, co-author, editor
    PRIMARY KEY (book_id, author_id)
);

-- Members table
CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    membership_type VARCHAR(20) DEFAULT 'standard', -- standard, premium
    is_active BOOLEAN DEFAULT TRUE
);

-- Loans table
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(book_id),
    member_id INTEGER REFERENCES members(member_id),
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(8,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active' -- active, returned, overdue
);

-- Create indexes for better performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_book ON loans(book_id);
CREATE INDEX idx_loans_status ON loans(status);

-- Add some sample data
INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British'),
('George', 'Orwell', '1903-06-25', 'British'),
('Harper', 'Lee', '1926-04-28', 'American'),
('F. Scott', 'Fitzgerald', '1896-09-24', 'American');

INSERT INTO publishers (name, address, founded_year) VALUES
('Penguin Random House', 'New York, USA', 1927),
('HarperCollins', 'London, UK', 1989),
('Simon & Schuster', 'New York, USA', 1924);

INSERT INTO categories (name, description) VALUES
('Fiction', 'Literary works of imagination'),
('Classic Literature', 'Timeless literary works'),
('Fantasy', 'Fantasy and magical realism'),
('Dystopian', 'Dystopian and science fiction');