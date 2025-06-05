select * from return_status;

-- Project Task
-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Update an Existing Member's Address
update members
set member_address = '125 Oak St'
where member_id = 'C103';

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';

-- Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id, count(*) as book_cnt
from issued_status
group by 1
having count(*) > 1;

-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_issued_cnt as
select b.isbn, b.book_title, count(ist.issued_id) as issue_count
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
group by b.isbn, b.book_title;

-- Retrieve All Books in a Specific Category
select * from books
where category = 'Classic';

--  Find Total Rental Income by Category:
select b.category, sum(b.rental_price), count(*)
from books b
join issued_status ist on b.isbn = ist.issued_book_isbn
group by 1;

-- List Members Who Registered in the Last 360 Days
select * from members
where reg_date >= current_date - interval 360 day;

-- List Employees with Their Branch Manager's Name and their branch details
select e.emp_id, e.emp_name, e.position, e.salary, b.*, e1.emp_name as manager
from employees e
join branch b on e.branch_id = b.branch_id
join employees e1 on b.manager_id = e1.emp_id;

-- Create a Table of Books with Rental Price Above a Certain Threshold
create table expensive_books as
select * from books
where rental_price > 7;
select * from expensive_books;

-- Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
where rs.return_id is null;

select * from return_status;



-- Advance SQL Query
-- Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

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

-- Update Book Status on Return
/*
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).*/
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

-- Testing Queries in MySQL:

-- Check book info
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

-- Check issued status
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

-- Check return status
SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');

/*Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and 
the total revenue generated from book rentals.*/

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

/*CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months.*/
create table active_members as
select m.member_id, m.member_name, m.member_address from members m
join issued_status ist on m.member_id = ist.issued_member_id
where ist.issued_date >= current_date() - interval 2 month
order by member_id;

select * from active_members;

/*Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/
select e.emp_name, count(ist.issued_id) as no_of_books_processed, b.* from employees e
join issued_status ist on e.emp_id = ist.issued_emp_id
join branch b on e.branch_id = b.branch_id
group by e.emp_name, b.branch_id
order by no_of_books_processed desc
limit 3;

/*Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the 
status "damaged" in the books table. Display the member name, book title, and 
the number of times they've issued damaged books.*/
-- return_status-issued_status
select m.member_name, ist.issued_book_name, count(rs.book_quality) as damaged_book_count from return_status rs
join issued_status ist on rs.issued_id = ist.issued_id
join members m on ist.issued_member_id = m.member_id
where rs.book_quality = "Damaged"
group by m.member_id,1, 2;

/*Stored Procedure Objective: Create a stored procedure to manage the status of books in a library 
system. Description: Write a stored procedure that updates the status of a book in the library based
on its issuance. The procedure should function as follows: The stored procedure should take the 
book_id as an input parameter. The procedure should first check if the book is available 
(status = 'yes'). If the book is available, it should be issued, and the status in the books table 
should be updated to 'no'. If the book is not available (status = 'no'), the procedure should 
return an error message indicating that the book is currently not available. */

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

CALL issue_book('IS155','C108','978-0-553-29698-2','E104');
CALL issue_book('IS156','C108','978-0-375-41398-8','E104');

/*Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify 
overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have 
issued but not returned within 30 days. The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines */

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