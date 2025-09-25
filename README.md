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

## Repository Structure

- `schemas/` - Database schema definitions for different use cases
- `examples/` - SQL example queries organized by topic
- `exercises/` - Hands-on exercises with solutions
- `docker/` - Docker setup for local database testing
- `data/` - Sample datasets for practice

## Prerequisites

- Basic understanding of data and tables
- Docker installed on your local machine (for running database instances)
- A SQL client tool (DBeaver, MySQL Workbench, pgAdmin, or command line)

## Getting Started

1. Clone this repository
2. Navigate to the repository root
3. Start the database using Docker: `docker-compose up -d`
4. Connect to the database using your preferred SQL client
5. Follow the exercises in the `exercises/` directory

## Supported Databases

This repository includes examples for:
- **PostgreSQL** (primary focus)
- **MySQL**
- **SQLite** (for lightweight local testing)

Each database has its own Docker configuration and specific examples highlighting unique features.
