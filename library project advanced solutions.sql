SELECT * from books;
SELECT * from members;
SELECT * from branch;
SELECT * from employees;
SELECT * from issued_status;
SELECT * from return_status;

-- project task
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"


INSERT INTO books(isbn ,book_title ,category,rental_price ,status,author,publisher) 
VALUES
('978-1-60129-456-2','To Kill a Mockingbird','Classic', 6.00,'yes', 'Harper Lee','J.B. Lippincott & Co.');


-- Task 2: Update an Existing Member's Address

SELECT * from MEMBERS;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
DELETE FROM issued_status
where issued_id = 'IS121';     


--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.


SELECT issued_emp_id,COUNT(*)
FROM issued_status
GROUP BY(1) HAVING COUNT(*)>1;


--3. CTAS (Create Table As Select)
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**


CREATE TABLE book_cnts
AS
SELECT 
		b.isbn,
		b.book_title,
		count(ist.issued_id) AS no_issued
from books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_cnts;

 /*4. Data Analysis & Findings
 The following SQL queries were used to address specific questions:
 Task 7. Retrieve All Books in a Specific Category:*/

SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT 
		b.category,SUM(rental_price),COUNT(*)
      from books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

--List Members Who Registered in the Last 180 Days:

SELECT * from members
--SELECT CURRENT_DATE
/*INSERT INTO members(member_id,member_name,member_address,reg_date)VALUES
('c120','surya bhai','123 laud st','2024-09-29');*/
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS';


--List Employees with Their Branch Manager's Name and their branch details:

SELECT * FROM branch;
SELECT * from employees;

SELECT 
		el.*,e2.emp_name AS manager,b.manager_id
		FROM employees AS el
		JOIN branch AS b
		ON el.branch_id = b.branch_id
		JOIN
		employees AS e2
		ON e2.emp_id = b.manager_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books 
AS
SELECT * from books
where rental_price > '7';

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * from issued_status AS ist
 LEFT JOIN
 return_status as rst
 ON ist.issued_id = rst.issued_id
 WHERE rst.return_id IS NULL;


/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.*/


SELECT 
		ist.issued_member_id,
		m.member_name,
		bk.book_title,
		ist.issued_date,
		CURRENT_DATE - ist.issued_date AS days_overdue
		FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
	books as bk
	ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
	return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1 ;


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).*/

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(222), p_issued_id VARCHAR(222), p_book_quality VARCHAR(222))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(222);
    v_book_name VARCHAR(222);
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records
/*
issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1';

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';*/

-- calling function 
CALL add_return_records('RS138', 'IS135','Good');

-- calling function 
CALL add_return_records('RS149', 'IS152', 'Good');


/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, 
the number of books returned, and 
the total revenue generated from book rentals.*/


CREATE TABLE  branch_performance
AS
SELECT  
		b.branch_id,e.emp_id,
		COUNT(ist.issued_id) AS books_issued,
		COUNT(rs.return_id) AS books_returned,
		SUM(bk.rental_price) AS rental_values
	FROM issued_status AS ist
	JOIN employees AS e
	ON ist.issued_emp_id = e.emp_id
	JOIN branch AS b
	ON e.branch_id = b.branch_id
	LEFT JOIN 
	return_status AS rs
	ON rs.issued_id = ist.issued_id
	JOIN 
	books AS bk
	ON ist.issued_book_isbn = bk.isbn
	GROUP BY 1,2;

	select * from branch_performance;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table -
active_members containing members who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members
AS 
SELECT * FROM members
WHERE member_id IN(
		SELECT DISTINCT issued_member_id 
		FROM issued_status
		WHERE issued_date >= CURRENT_DATE - INTERVAL'2MONTH'
);
SELECT * FROM active_members;


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.*/


SELECT
		e.emp_name,
		COUNT(ist.issued_id) AS books_issued,
		b.*
		FROM issued_status AS ist
		JOIN employees AS e
		ON ist.issued_emp_id = e.emp_id
		JOIN branch AS b
		ON e.branch_id = b.branch_id
GROUP BY 1,3;

/* Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/

select m.member_id,
		ist.issued_book_name AS book_title,
		COUNT(rs.book_quality) AS damaged_books
		FROM members AS m
		JOIN issued_status AS ist
		ON m.member_id = ist.issued_member_id
		JOIN return_status AS rs
		ON ist.issued_id = rs.issued_id
		WHERE rs.book_quality = 'Damaged'
		GROUP BY m.member_id,book_title;

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating -
that the book is currently not available.*/


CREATE OR REPLACE PROCEDURE issue_books(p_issued_id VARCHAR(222),
					 p_issued_member_id VARCHAR(222),
					 p_issued_book_isbn VARCHAR(222),
					 p_issued_emp_id VARCHAR(222))
LANGUAGE plpgsql
AS
$$
DECLARE
		v_status VARCHAR(222);
BEGIN
		SELECT status
		INTO v_status
		FROM books
		WHERE isbn = p_issued_book_isbn;
		IF v_status = 'yes' THEN

		INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		VALUES
		(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		RAISE NOTICE'BOOKS RECORDS ADDED SUCCESSFULLY FOR BOOKS ISBN :%',p_issued_book_isbn;
	ELSE
		RAISE NOTICE'BOOKS RECORDS NOT AVAILABLEFOR BOOKS ISBN :%',p_issued_book_isbn;
	END IF;
	END;
	$$

CALL issue_books('IS155', 'C107', '978-0-14-118776-1', 'E104');
CALL issue_books('IS156', 'C107', '978-0-7432-7357-1', 'E102');

