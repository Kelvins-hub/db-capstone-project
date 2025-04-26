create database DB_Optimization;

use DB_Optimization;

#✅ Example:🔹 1. How UNION is Used

SELECT city FROM customers
UNION
SELECT city FROM suppliers;

#This will return a distinct list of cities from both tables.
#Duplicate city names will appear only once.


#✅ Example:🔹 2. How UNION ALL is Used

SELECT city FROM customers
UNION ALL
SELECT city FROM suppliers;
#This returns all cities, including duplicates.
#Faster than UNION because the database doesn’t need to sort and remove duplicates.

-- ----------------------------------------------------------------------------------

#Inefficient Query (function on column): USING FUNCTIONS IN PREDICATE

SELECT * FROM orders
WHERE YEAR(order_date) = 2024;
#This applies the YEAR() function to every order_date.
#Even if order_date is indexed, the index won’t be used because 
#the function masks the actual column value.


#✅ Efficient Version (function on value instead):

SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';
#Now you’re comparing the column directly — no function applied.
#The database can use the index on order_date to speed up the query.

-- -------------------------------------------------------------------------------
#✅ Best Practice (select only what's needed):
SELECT first_name, last_name, department FROM employees;
#Faster and more efficient.
#Easier to read and maintain.
#Minimizes data transfer from the database.

#❌ Bad Practice (selecting all columns):
SELECT * FROM employees;
#Pulls all columns, even if you only need one or two.
#Wastes memory, bandwidth, and processing time.
#Breaks if the table structure changes later.

-- -----------------------------------------------------------------------------
/* explain statements in sql helps you to inspect your query plan and find ways to improve 
your query performane. its used to troubleshoot and optimize query performance.
for example....
Let's walk through an example from start to finish, including:
✅ Creating a table with data
❌ An inefficient query and its EXPLAIN output
✅ An efficient query with indexing and its EXPLAIN output
🔍 Comparison of both execution plans

*/

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(50),
    age INT,
    salary DECIMAL(10,2)
);

-- Insert 1,000 random employees
INSERT INTO employees (name, department, age, salary)
SELECT 
    CONCAT('Employee_', FLOOR(RAND() * 10000)),
    ELT(FLOOR(1 + (RAND() * 5)), 'HR', 'Engineering', 'Sales', 'Finance', 'IT'),
    FLOOR(20 + (RAND() * 40)),
    ROUND(30000 + (RAND() * 70000), 2)
FROM
    information_schema.tables
LIMIT 1000;
-- ----------------------------
SELECT COUNT(*) 
FROM employees; #to count the number of rows in a table #442 rows are in the table

-- -----------------------------------
#🔹 Step 2: Inefficient Query

-- Inefficient query: no index on department column
SELECT * FROM employees WHERE department = 'Sales';

-- -------------------------------------
# 🧪 EXPLAIN Output:
EXPLAIN SELECT * FROM employees WHERE department = 'Sales'; 
/*⚠️ Interpretation:
type = ALL: Full table scan (scans all 442 rows)

key = NULL: No index used

Extra = Using where: Just filtering, but not efficiently */
-- --------------------------------------
CREATE INDEX idx_department ON employees(department);
/*How it Works
1. Index Creation: The CREATE INDEX statement creates a new index named idx_department 
on the employees table.
2. Column Specification: The index is created on the department column, 
which means the index will store the values in this column in a sorted order.
3. Index Type: By default, this will create a B-tree index 
(or a similar index type depending on the database management system), 
which allows for efficient lookup, insertion, and deletion operations.

What Happens
1. Separate Data Structure: The index is stored separately from the table data.
2. Faster Lookups: The index allows the database to quickly locate specific rows 
based on the indexed column(s).
3. No Visible Change: The index doesn't change the table's structure or add a new column.

Analogy
Think of an index like a book's index. Just as a book's index helps you quickly 
find specific topics, a database index helps the database quickly find specific data. 

Considerations
1. Index Maintenance: Indexes require additional storage space and can slow down 
write operations (INSERT, UPDATE, DELETE) since the index needs to be updated.
2. Index Selection: Choose columns for indexing based on query patterns and 
performance requirements.
*/

#Now rerun the same query:
-- Efficient query: with index on department
SELECT * FROM employees WHERE department = 'Sales';

#🧪 EXPLAIN Output:

EXPLAIN SELECT * FROM employees WHERE department = 'Sales';

/*✅ Interpretation:
type = ref: Index used to filter rows (much better than ALL)

key = idx_department: Index is being used

rows = ~91: Only 91 rows scanned instead of 442 */

#COMPOSITE INDEX

/*✅ It's absolutely possible (and sometimes very beneficial) to create a composite index
 (also called a multi-column index) in MySQL.
 🔹 Syntax: Create Index on Multiple Columns

CREATE INDEX index_name ON table_name (column1, column2, ...);
For example:
CREATE INDEX idx_dept_age ON employees(department, age);
This creates an index on both department and age.

🔍 How Composite Indexes Work
A composite index works from left to right — this is super important!

Given:
CREATE INDEX idx_dept_age ON employees(department, age);
This index can be used for queries like:

-- ✅ uses the index
SELECT * FROM employees WHERE department = 'Sales';

-- ✅ uses the index
SELECT * FROM employees WHERE department = 'Sales' AND age > 30;

-- ❌ cannot use the index
SELECT * FROM employees WHERE age > 30;
Because department comes first, MySQL can’t use the index if only age is in the WHERE clause.

*/
#SELECT FROM Employees WHERE fullname LIKE %tolo;
#the above statement would prevent the use of Indexes so you can alter the table
#add a new column and reverse the fullname #just an option sha. not really clear how it works

-- -----------------------------------------------------------------------------
#Each time you create a stst, it has to be compliled and parsed(to examine computer data
#and change it into a form that the computer can read and understand) before it can be executed
#this process utilizes lots of resources.
/*
A prepared statement is a precompiled SQL statement. 
It allows you to define the SQL structure once, then supply values (parameters)
later when executing the statement. It consists of two main steps:

Preparation: The SQL statement is sent to the database server and compiled.
Execution: Values are bound to the parameters, and the statement is executed.

A SQL prepared statement is a feature used to execute the same (or similar) SQL statements 
repeatedly with high efficiency and enhanced security. It's particularly useful when 
you're dealing with dynamic values, such as user inputs, and helps prevent SQL injection 
attacks(Prepared statements separate SQL logic from user input, so even if someone 
tries to insert malicious code, it’s treated as data, not as part of the SQL query.).

*/

#syntax
#PREPARE Statement_name FROM 'SQL QUERY';

#lets create a table where we can use it
#🧾 Sample Table: users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('admin', 'admin@domain.com');

#🎯 Goal : We want to get the user's details by email safely using a prepared statement.

-- 1. Prepare the SQL statement with a placeholder
PREPARE getUser FROM 'SELECT * FROM users WHERE email = ?';

-- 2. Set the parameter value
SET @user_email = 'jane@example.com';

-- 3. Execute the prepared statement
EXECUTE getUser USING @user_email; 

-- 4. Clean up
DEALLOCATE PREPARE getUser; -- once completed, step 3 cannot be run again. its would 
								-- return unknown prepared statement.

-- --------------------------------------------------------------------------------
#📌 What Is a Common Table Expression (CTE)?
#A CTE is a temporary result set that you can reference within a SELECT, INSERT, 
#UPDATE, or DELETE statement. Think of it like a named subquery that makes your SQL 
#more readable and often more maintainable

#🧠 Basic Syntax

WITH cte_name AS (
 --   SELECT ... -- your query
)-- this is a single cte

SELECT * FROM cte_name;
-- -------------------------------------
#lets alter the existing table to enable us use it
alter table users
Add column role VARCHAR(20);

select * from users;
UPDATE  users
SET role = 
    CASE 
        WHEN id = 1 THEN 'user'
        WHEN id = 2 THEN 'admin'
        WHEN id = 3 THEN 'user'
        ELSE role 
    END
WHERE id IN (1, 2, 3);

select * from users;

#senario
#Now, let’s say we want to get only users (not admins), and we want to sort them
 #by username. Here’s how we can use a CTE:
 
 #creation of a cte and it's utilization all in one statment
WITH non_admins AS (SELECT * FROM users WHERE role = 'user')
SELECT id, username FROM non_admins ORDER BY username;

-- ----------------------------------
# example of multiple CTEs

CREATE TABLE sales (
    id INT,
    product VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2)
);

INSERT INTO sales (id, product, quantity, price) VALUES
(1, 'Pen', 10, 1.50),
(2, 'Notebook', 5, 3.00),
(3, 'Pen', 20, 1.50),
(4, 'Notebook', 10, 3.00);

/*🎯 Goal:
We want to:
Calculate total quantity sold for each product.

Calculate total revenue for each product.

Display both using multiple CTEs. */

WITH total_quantity AS (
    SELECT product, SUM(quantity) AS total_qty
    FROM sales
    GROUP BY product
),
#with keyword is not needed multiple times only once
total_revenue AS (
    SELECT product, SUM(quantity * price) AS total_rev
    FROM sales
    GROUP BY product
)
#now this is the desired output all in the same block of code with the creation stat
SELECT 
    q.product,
    q.total_qty,
    r.total_rev
FROM total_quantity q
JOIN total_revenue r ON q.product = r.product; 
# notice that the cte's are separated by commas and there is only one ;

#The truth is:
#👉 CTEs mostly improve readability and structure.
#But when it comes to performance, it's a bit more nuanced. 

-- -------------------------------------------------------------------------
/*🧾 What is an SQL Transaction?
An SQL transaction is a group of one or more SQL statements that are executed as a
 single unit. The goal is that either all of them succeed or none of them
 do—this keeps your data safe and consistent.
 
 🔐 Why Use Transactions?
To protect data during critical operations like:
Bank transfers
Inventory updates
Booking systems
Any situation where partial changes can cause problems

✅ Key Properties: ACID

Property	Meaning
Atomicity	All statements succeed, or all fail—no partial updates.
Consistency	Data stays valid before and after the transaction.
Isolation	Transactions don’t interfere with each other (you can control this).
Durability	Once committed, changes are saved even if the system crashes.*/

#🧪 Basic Transaction Example (Bank Transfer)

#basic syntax is 
# start transaction; or begin;
# COMMIT;
# ROLLBACK; only when necessary 

CREATE TABLE accounts (
    id INT,
    name VARCHAR(50),
    balance DECIMAL(10,2)
);

INSERT INTO accounts (id, name, balance) VALUES
(1, 'Alice', 1000.00),
(2, 'Bob', 500.00);

select * from accounts;

#Now we want to transfer $100 from Alice to Bob safely:
START TRANSACTION; #marks the point where the process starts
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT; -- confirms and saves the changes

#If something goes wrong (e.g., Alice doesn’t have enough money), we can undo:
#ROLLBACK; -- cancels all changes in the transaction

/* 💡 Syntax Variations

Action						Command
Start a transaction			START TRANSACTION; or BEGIN;
Commit changes				COMMIT;
Undo changes				ROLLBACK;*/

/*✅ Summary
Transactions are like a safety net for your database operations. They’re essential when data integrity matters, especially in:

Financial systems

Multi-step updates

Complex inserts/updates/deletes*/

#EXAMPLE 2
/*Scenario: Placing an Order
Let's assume you have two tables:

products (with product inventory)

orders (with customer orders)*/
SHOW TABLES;

CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    stock INT
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity INT,
    order_date DATETIME,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO products (id, name, price, stock) VALUES
(1, 'Laptop', 999.99, 10),
(2, 'Smartphone', 499.99, 15),
(3, 'Headphones', 199.99, 25),
(4, 'Mouse', 29.99, 50),
(5, 'Keyboard', 49.99, 30);


SELECT * FROM products;

/*Step-by-Step Transaction:
Objective: A customer is placing an order. We need to:

Check inventory to ensure there's enough stock.

Update inventory after the order.

Insert the order into the orders table. */


START TRANSACTION;

-- Try to update the stock
UPDATE products
SET stock = stock - 3
WHERE id = 1 AND stock >= 3;

-- Check if any row was affected
IF ROW_COUNT() > 0 THEN
    -- Insert the order only if stock was updated
    INSERT INTO orders (product_id, quantity, order_date)
    VALUES (1, 3, NOW());
    
    COMMIT;
ELSE
    -- Not enough stock, rollback
    ROLLBACK;
END IF;

#for this particular example 
/*⚠️ Note: The above control logic needs to be inside a stored procedure, function,
 or controlled by application code (like in Python, PHP, Java, etc.) 
 — standard SQL doesn’t allow IF statements outside stored programs.*/






