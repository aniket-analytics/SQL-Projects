# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/aniket-analytics/SQL-Projects/Library-Management/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/aniket-analytics/SQL-Projects/Library-Management/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

```sql
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;
```

-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```

-- Task 2: Update an Existing Member's Address
```sql
UPDATE members
SET member_address = '892 Maple St'
WHERE member_id = 'C105';
SELECT * FROM members;
```

-- Task 3: Delete a Record from the Issued Status Table. 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121'
```
-- Task 4: List Members Who Have Issued More Than One Book. 
-- Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT 
	issued_emp_id,
	COUNT(*) AS total_books
FROM
	issued_status
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY total_books DESC
```
-- CTAS(CREATE TABLE AS SUMMARY)
-- Task 5: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
```sql
CREATE TABLE total_book_cnt 
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(i.issued_id) AS total_book_issued
FROM books b	
JOIN issued_status i 
ON i.issued_book_isbn = b.isbn
GROUP BY 1, 2
```
-- Task 6: Find Total Rental Income by Category:
```sql
SELECT * FROM issued_status
SELECT * FROM books

SELECT
	b.category,
	SUM(rental_price) AS total_rental_income,
	COUNT(*) 
FROM 
	issued_status i
JOIN books b 
ON i.issued_book_isbn = b.isbn
GROUP BY 1
ORDER BY 2 DESC
```
-- Task 7: List Members Who Registered in the Last 180 Days:
```sql
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES('C120', 'Franky', '284 Cedar St', '2025-02-02');


INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES('C121', 'Brook', '850 Maple St', '2025-02-02');

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```
-- Task 8: List Employees with Their Branch Manager's Name and their branch details:
```sql
SELECT * FROM employees
SELECT * FROM branch

SELECT 
	e.*,
	b.manager_id,
	m.emp_name AS manager_name
FROM 
	employees e
JOIN branch b 
ON e.branch_id = b.branch_id
JOIN employees m 
ON m.emp_id = b.manager_id
```
-- Task 9: Retrieve the List of Books Not Returned Yet
```sql
SELECT * FROM return_status
SELECT * FROM issued_status

SELECT DISTINCT i.issued_book_name
FROM issued_status i
LEFT JOIN return_status r 
ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL
```
-- Task 10: Display books that have never been issued.
```sql
SELECT 
	b.*,
	i.issued_id
FROM books b
LEFT JOIN issued_status i
ON i.issued_book_isbn = b.isbn 
WHERE i.issued_id IS NULL
```
-- Task 11: List all employees along with the names of the branches they are assigned to.
```sql
SELECT 
	e.*,
	b.branch_address,
	b.contact_no
FROM employees e
LEFT JOIN branch b
ON e.branch_id = b.branch_id
```
-- Task 12: List all return records along with corresponding member names and book titles.
```sql
SELECT 
	r.return_id,
	r.issued_id,
	m.member_name,
	i.issued_book_name,
	r.return_date,
	r.book_quality
FROM issued_status i
JOIN members m ON m.member_id = i.issued_member_id
JOIN  return_status r ON r.issued_id = i.issued_id
```
-- Task 13: Use a CTE to compute average rental price per category and average rental price should be greater than or equal to 7.
```sql
WITH avg_rental_price AS(
	SELECT 
		category,
		AVG(rental_price) AS avg_price
	FROM
		books
	GROUP BY 1	
)
SELECT * FROM avg_rental_price
WHERE avg_price >= 7
ORDER BY avg_price DESC
```

-- Task 14: With a CTE, find members who issued more than 3 books in total.
```sql
WITH cnt_book AS(
	SELECT
		issued_emp_id,
		COUNT(*) AS total_book
	FROM issued_status
	GROUP BY 1
)
SELECT * FROM cnt_book
WHERE total_book >= 3 
ORDER BY total_book DESC
```

-- Task 15: Find the branch that has the highest number of issued books.
```sql
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;

WITH high_issue_book AS(
	SELECT 
		b.branch_id,
		COUNT(i.issued_id) AS high_no_book 
	FROM branch b
	JOIN employees e ON e.branch_id = b.branch_id
	JOIN issued_status i ON i.issued_emp_id = e.emp_id
	GROUP BY 1
)
SELECT * FROM high_issue_book
ORDER BY high_no_book DESC
```

-- Task 16: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
```sql
SELECT 
	i.issued_member_id,
	m.member_name,
	b.book_title,
	i.issued_date,
	rs.return_date,
	(CURRENT_DATE - i.issued_date) AS Overdue
FROM issued_status i
JOIN members m
ON m.member_id = i.issued_member_id
JOIN books b 
ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status rs
ON rs.issued_id = i.issued_id
WHERE 
	rs.return_date IS NULL
	AND
	(CURRENT_DATE - i.issued_date) > 30
ORDER BY 1
```
