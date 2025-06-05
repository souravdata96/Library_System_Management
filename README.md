# Library System Management

## Project Overview

**Project Title**: Library System Management 
**Level**: Intermediate  
**Database**: `library_management_system_p2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/souravdata96/Library_System_Management/blob/main/Library_Management.png)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/souravdata96/Library_System_Management/blob/main/Library_ERD.png)

- **Database Creation**: Created a database named `library_management_system_p2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_management_system_p2;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(55),
    contact_no VARCHAR(10)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
	emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(25),
    position VARCHAR(15),
    salary INT,
    branch_id VARCHAR(25)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR(10) PRIMARY KEY,
    mamber_name VARCHAR(25),
    member_address VARCHAR(75),
    reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(75),
    category VARCHAR(10),
    rental_price FLOAT,
    status VARCHAR(15),
    author VARCHAR(35),
    publisher VARCHAR(55)
    
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(75),
    issued_date DATE,
    issued_book_isbn VARCHAR(25),
    issued_emp_id VARCHAR(10)
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(75),
    return_date DATE,
    return_book_isbn VARCHAR(20)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address = '125 Oak St'
where member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
select * from issued_status
where issued_emp_id = 'E101';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issued_emp_id, count(*) as book_cnt
from issued_status
group by 1
having count(*) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_issued_cnt as
select b.isbn, b.book_title, count(ist.issued_id) as issue_count
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
group by b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select * from books
where category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select b.category, sum(b.rental_price), count(*)
from books b
join issued_status ist on b.isbn = ist.issued_book_isbn
group by 1;
```

9. **List Members Who Registered in the Last 360 Days**:
```sql
select * from members
where reg_date >= current_date - interval 360 day;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e.emp_id, e.emp_name, e.position, e.salary, b.*, e1.emp_name as manager
from employees e
join branch b on e.branch_id = b.branch_id
join employees e1 on b.manager_id = e1.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table expensive_books as
select * from books
where rental_price > 7;
select * from expensive_books;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
where rs.return_id is null;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    DATEDIFF(CURRENT_DATE(), ist.issued_date) AS over_due_days
FROM 
    issued_status ist
JOIN 
    members m ON ist.issued_member_id = m.member_id
JOIN 
    books b ON ist.issued_book_isbn = b.isbn
LEFT JOIN 
    return_status rs ON ist.issued_id = rs.issued_id
WHERE 
    rs.return_date IS NULL
    AND DATEDIFF(CURRENT_DATE(), ist.issued_date) > 30
ORDER BY 
    ist.issued_member_id;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

DELIMITER //

CREATE PROCEDURE add_return_records(
	IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
	DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);
    
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE(), p_book_quality);
    
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1;
    
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;
    
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS Message;
    
    END //
    
    DELIMITER ;


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_reports as
select br.branch_id, br.manager_id, count(ist.issued_id) as no_of_books_issued,
count(rs.return_id) as no_of_books_returned, sum(b.rental_price) as total_revenue
from issued_status ist
join employees e on ist.issued_emp_id = e.emp_id
join branch br on e.branch_id = br.branch_id
left join return_status rs on ist.issued_id = rs.issued_id
join books b on ist.issued_book_isbn = b.isbn
group by 1, 2;

select * from branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create table active_members as
select m.member_id, m.member_name, m.member_address from members m
join issued_status ist on m.member_id = ist.issued_member_id
where ist.issued_date >= current_date() - interval 2 month
order by member_id;

select * from active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select e.emp_name, count(ist.issued_id) as no_of_books_processed, b.* from employees e
join issued_status ist on e.emp_id = ist.issued_emp_id
join branch b on e.branch_id = b.branch_id
group by e.emp_name, b.branch_id
order by no_of_books_processed desc
limit 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
select m.member_name, ist.issued_book_name, count(rs.book_quality) as damaged_book_count from return_status rs
join issued_status ist on rs.issued_id = ist.issued_id
join members m on ist.issued_member_id = m.member_id
where rs.book_quality = "Damaged"
group by m.member_id,1, 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

DROP PROCEDURE IF EXISTS issue_book;
DELIMITER $$

/* ---------- 2. Create the procedure */
CREATE PROCEDURE issue_book(
    IN p_issued_id         VARCHAR(10),
    IN p_issued_member_id  VARCHAR(30),
    IN p_issued_book_isbn  VARCHAR(30),
    IN p_issued_emp_id     VARCHAR(10)
)
BEGIN
    /* variable section must come first in MySQL */
    DECLARE v_status VARCHAR(10);

    /* ---------- 3. Check availability */
    SELECT status               -- grab the current “yes / no”
      INTO v_status             -- store it in our local variable
      FROM books
     WHERE isbn = p_issued_book_isbn
     LIMIT 1;                   -- protects against accidental duplicates

    /* ---------- 4. Business logic */
    IF v_status = 'yes' THEN
        /* 4a.  Insert lending record */
        INSERT INTO issued_status
              (issued_id, issued_member_id, issued_date,
               issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE,
                p_issued_book_isbn, p_issued_emp_id);

        /* 4b.  Flip book to “no” (checked out) */
        UPDATE books
           SET status = 'no'
         WHERE isbn = p_issued_book_isbn;

        /* 4c.  Friendly notice (MySQL has no RAISE NOTICE) */
        SELECT CONCAT('Book records added successfully for book isbn : ',
                      p_issued_book_isbn) AS info_msg;

    ELSE
        /* 4d.  Book wasn’t available */
        SELECT CONCAT('Sorry, the requested book is unavailable.  book_isbn: ',
                      p_issued_book_isbn) AS info_msg;
    END IF;
END $$
DELIMITER ;

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
CREATE TABLE overdue_books_summary AS
SELECT 
    ist.issued_member_id,
    
    COUNT(
        CASE 
            WHEN (
                (rs.return_date IS NULL AND DATEDIFF(CURRENT_DATE(), ist.issued_date) > 30) OR
                (rs.return_date IS NOT NULL AND DATEDIFF(rs.return_date, ist.issued_date) > 30)
            )
            THEN 1
            ELSE NULL
        END
    ) AS overdue_books_count,

    SUM(
        CASE 
            WHEN (
                rs.return_date IS NULL AND DATEDIFF(CURRENT_DATE(), ist.issued_date) > 30
            ) THEN DATEDIFF(CURRENT_DATE(), ist.issued_date) * 0.50
            WHEN (
                rs.return_date IS NOT NULL AND DATEDIFF(rs.return_date, ist.issued_date) > 30
            ) THEN DATEDIFF(rs.return_date, ist.issued_date) * 0.50
            ELSE 0
        END
    ) AS `Total Fines $`,

    COUNT(*) AS total_books_issued

FROM 
    issued_status ist
LEFT JOIN 
    return_status rs ON ist.issued_id = rs.issued_id

GROUP BY 
    ist.issued_member_id
ORDER BY 
    ist.issued_member_id;
    
select issued_member_id, overdue_books_count, `Total Fines $`from overdue_books_summary
where overdue_books_count > 0;
```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

✨ This project demonstrates my SQL proficiency and passion for database management and analytical problem-solving. I'm actively pursuing opportunities in data analytics—let’s connect if you're looking for someone who turns data into actionable insights.

## Author - souravdata96

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/sourav-mishra7207/)

Thank you for your interest in this project!
