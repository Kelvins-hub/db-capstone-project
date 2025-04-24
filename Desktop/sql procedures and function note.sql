CREATE DATABASE functions_procedure_note;

use functions_procedure_note;

-- varaible declearation

-- example of normal use of decleared variable that is not within a stored procedure
SET @myVar = 100; -- is a user-defined session variable, it disappears at the end of session
SELECT @myVar + 50 AS result;

-- -----------------------------------------------------------------------------------------------------
CREATE TABLE ordersdata (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2) #can take max of 10 digits, and can have max 2 decimal points
);

INSERT INTO ordersdata (customer_id, order_date, amount) VALUES
(42, '2025-04-15', 120.50),
(42, '2025-04-18', 75.00),
(17, '2025-04-16', 200.00),
(25, '2025-04-19', 150.25),
(42, '2025-04-20', 90.00);

SET @customer_id = 42; -- is a user-defined session variable, it disappears at the end of session

SELECT * FROM ordersdata WHERE customer_id = @customer_id;

-- Why it's helpful:Easy to change the @customer_id in one place.Reduces errors &saves time too

-- -----------------------------------------------------------------------------------------------------
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT NOT NULL
);

INSERT INTO inventory (product_id, product_name, quantity) VALUES
(1, 'Widget A', 5),
(2, 'Widget B', 15),
(3, 'Widget C', 0);


-- Example using DECLARE in a stored procedure:
drop procedure if exists check_stock;

DELIMITER //


CREATE PROCEDURE check_stock(IN prod_id INT)
BEGIN
   DECLARE stock_count INT;

   SELECT quantity INTO stock_count
   FROM inventory
   WHERE inventory.product_id = prod_id;

   IF stock_count < 10 THEN
      SELECT 'Restock needed' AS Stock_Status;
   ELSE
      SELECT 'Stock level OK'AS Stock_Status;
   END IF; #why do i need to add END IF????? #MySQL requires you to mark its end using END IF;
END //

DELIMITER ;


CALL check_stock(1);  -- should return 'Restock needed'
-- --------------------------------------------------------------------------------------------------------------
#STORED PROCEDURES
-- there are four types of stored procedures
-- 1. No Parameters (No IN, OUT, or INOUT. Fixed logic.	e.g List all users, clear old logs)
-- 2. IN Parameters Only (Accepts input, does something with it. e.g Calculate tax, find user by ID)
-- 3. OUT Parameters Only (No input; returns something back. e.g Generate a fixed report and return totals)
-- 4. Mix of IN, OUT, INOUT (Accepts input, returns output, or both. e.g Process order, calculate and return bonus)


-- EXAMPLE of NO Parameters
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS show_all_products()
BEGIN
   SELECT * FROM products;
END;

DELIMITER ;

-- ---------------------------------------------------------------------------------------------------------------

-- EXAMPLE of IN Parameters
create procedure calculate_tax (in Salary int)

select salary *0.1 as tax;

call calculate_tax (4000000);

-- ------------------------------------------------------------------------------------------------------------
#another example of In parameter
#drop procedure if exists after_deductions; 

create procedure after_deductions (in Salary int)

select Salary - (Salary *0.18) as after_deductions;

call after_deductions (396000);
-- ----------------------------------------------------------------------------------------------------------
-- EXAMPLE of OUT Parameters
CREATE TABLE products_stock (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);


INSERT INTO products_stock (product_name, category, price, stock_quantity) VALUES
('Laptop Pro 15', 'Electronics', 1200.00, 25),
('Wireless Mouse', 'Accessories', 25.50, 100),
('Gaming Keyboard', 'Accessories', 79.99, 60),
('Office Chair', 'Furniture', 150.00, 15),
('Noise Cancelling Headphones', 'Electronics', 199.99, 40),
('Smartwatch Series 5', 'Wearables', 299.99, 30),
('USB-C Hub', 'Accessories', 45.00, 75),
('Desk Lamp', 'Furniture', 34.95, 20),
('External Hard Drive 1TB', 'Storage', 89.50, 50),
('Bluetooth Speaker', 'Electronics', 59.99, 80);

select * from products_stock;
drop Procedure if exists get_product_count;

DELIMITER //
CREATE PROCEDURE get_product_count(OUT total INT)
BEGIN
   SELECT COUNT(*) INTO total FROM products_stock;
END; //

delimiter ;
#total in this proc is a variable that holds the result of the COUNT(*) query and returns it to the caller.

#how do i use call the above procedure ???????
#3 STEP PROCESS TO USE ENABLE YOU ACCESS AND RETRIVE RESULT OF THIS PROCEDURE

#Step 1: Declare a Session Variable

SET @total = 0; #This will hold the output from the procedure.

#Step 2: Call the Stored Procedure

CALL get_product_count(@total); 

#Step 3: Retrieve the Result

SELECT @total;

-- ----------------------------------------------------------------------------------------------------------
select * from products;

ALTER TABLE products
RENAME COLUMN ProductID TO product_id;


drop procedure if exists update_price;
#example of IN, OUT, and/or INOUT Combined procedure

drop Procedure if exists update_price;
DELIMITER //

CREATE PROCEDURE update_price(IN prod_id INT, INOUT price DECIMAL(10,2))
BEGIN
   -- TASK-1: Update product where product_id matches the input
   UPDATE products 
   SET price = price * 1.1 
   WHERE products.product_id = prod_id;
-- without task 1, this procedure would provide same result as when there is task 1 & 2.
-- only that, the price in database would not change. task 1, is only to ensure a price update on 
-- the DB not on a singular item to be purchased  
   
   -- TASK-2: Update the INOUT price variable
   SET price = price * 1.1;
END;
//

DELIMITER ;

#how do i use call the above procedure ??????? ANS: 3 STEPS

#🔹 Step 1: Initialize the INOUT variable

SET @price = 100.00; #Set a session variable for the price, which will also receive the output.

#🔹 Step 2: Call the Procedure

CALL update_price(1, @price); #Provide a valid prod_id and the @price variable.
#This will update the price of product with ID 1 in the products table (price *= 1.1).
#It will also update the session variable @price to reflect the new price (price *= 1.1).

SELECT @price;

-- -------------------------------------------------------------------------------------------------------
## USER DEFINED FUNCTIONS in sql
/*These are custom functions written by users to perform specific logic or calculations 
that aren’t already built into SQL
they cant modify a DB -- No (can’t use INSERT, UPDATE) BUT are reuseable
*/


-- basic structure of a UDF 
-- 1. the create fucntion keyword -- 
-- 2. the function name 
-- 3. is input paramenter & data type in parentensis   e.g (salary int) or  (cost decimal (10, 2))
-- 4. the the return keyword must come before the deterministic or not deterministic
-- 5. BEGIN and END block with code  body inside
-- 6. the syntax to use a function is SELECT function_name(input_parameter);
 
drop function if exists add_five;
DELIMITER //
CREATE FUNCTION add_five(x INT)
RETURNS INT
DETERMINISTIC
BEGIN
   RETURN x + 5;
END;  //

DELIMITER;
-- ----------------------------------------------
SELECT add_five(50); # there is a problem utilizing the function, we solve this later


-- --------------------------------------------------------------------------------------------------------
drop function if exists calculate_tax;
DELIMITER //

CREATE FUNCTION calculate_tax(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC 

/* DETERMINISTIC means the function returns the same result for the same input, this 
this means that a function can also be "NOT DETERMINISTIC". 

Best Practice
Use DETERMINISTIC if your function only uses input parameters and math/string logic.
Use NOT DETERMINISTIC if it involves NOW(), RAND(), UUID(), or querying other tables.
*/

BEGIN
   DECLARE tax DECIMAL(10,2); #TASK 1
   SET tax = salary * 0.18;  #TASK 2
   RETURN tax;   #TASK 3
END //

DELIMITER ;

select calculate_tax(1000000);
-- ---------------------------------------------------------------------------------------------------------
#example of a UDF having IF BLOCK
DELIMITER $$

CREATE FUNCTION get_grade(score INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE grade VARCHAR(10);

    IF score >= 70 THEN
        SET grade = 'Distinction';
    ELSEIF score >= 50 THEN
        SET grade = 'Pass';
    ELSE
        SET grade = 'Fail';
    END IF;

    RETURN grade; #NOTE THAT THE RETURN IS ALWAYS THE LAST THING BEFORE THE END 
					#IN A BEGIN-END BLOCK IN SQL FUNCTIONS
                    #you must tell the function what final output will be
END$$

DELIMITER ;
-- -----------------------------------------------------------------------------------------------------------
#MORE COMPLEX STORED PROCEDURE
/* this procedure is to determine the products that are in the products tables and arrange them 
into two category. high price products and low price product  based on their price. this is 
necessary so we can know what products to add a discount on.*/

-- create table that the proc will act on

-- Step 1: Create the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    InStock BOOLEAN
);

-- Step 2: Insert 5 sample rows into Products
INSERT INTO Products (ProductID, ProductName, Category, Price, InStock) VALUES
(1, 'Wireless Mouse', 'Electronics', 25.99, TRUE),
(2, 'Coffee Mug', 'Kitchenware', 8.50, TRUE),
(3, 'Notebook', 'Stationery', 3.20, FALSE),
(4, 'Bluetooth Speaker', 'Electronics', 49.99, TRUE),
(5, 'Desk Lamp', 'Furniture', 18.75, TRUE);

select * from Products;

#ALTER TABLE Products --table was not altered 
#DROP COLUMN InStock; -- column was not dropped
-- --------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetProductSummary;

DELIMITER //
CREATE PROCEDURE GetProductSummary (OUT NumberOflowPriceProducts int, 
OUT NumberOfHighPriceProducts int)

BEGIN 
	SELECT COUNT(product_id) INTO NumberOflowPriceProducts 
    FROM Products WHERE Price < 30;
    
    SELECT COUNT(product_id) INTO NumberOfHighPriceProducts 
    FROM Products WHERE Price > 30;
    
END //  -- ✅ Marks the real end of the CREATE PROCEDURE block. without // proc will not be created

DELIMITER ; 
    
-- -------------------------------------------------------------------------------------------------------
-- call GetProductSummary (productID); would not work in this case senario. this is because 
#GetProductSummary was NOT DESIGNED to accept a ProductID — it takes two OUT parameters,
# and those aren’t for input, they’re for output.

/*CREATE PROCEDURE GetProductSummary (
    OUT NumberOflowPriceProducts INT, 
    OUT NumberOfHighPriceProducts INT
) */

#Step 1: Create session variables to receive the output
SET @low = 0;
SET @high = 0;
#These @low and @high are placeholders for the procedure to put the results in.

# Step 2: Call the procedure
CALL GetProductSummary(@low, @high);
#This runs your procedure and puts:
#The count of low-price products in @low
#The count of high-price products in @high

#Step 3: See the results
SELECT @low AS LowPriceProducts, @high AS HighPriceProducts;
-- ---------------------------------------------------------------------------------------------- 

 /*Stored Procedure
A stored procedure is a group of SQL statements stored in the database that can perform operations
 like inserting, updating, deleting, or querying data. 
 It can return results via OUT or INOUT parameters or result sets, 
 and is generally used to perform actions.

Think of it like a script you run to perform a task.

🔹 Function
A function is a database object that takes input, performs a calculation or task, and returns a 
single value directly. It must return a value, and it's mainly used within SQL 
expressions (like in SELECT, WHERE, etc.).

Think of it like a calculator that gives you one specific answer.*/





#ANOTHER EXAMPLE OF STORED PROCEDURE 

#lets create a table that the procedure would work on 
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Quantity INT,
    Cost DECIMAL(7,2),
    OrderDate DATE
);

INSERT INTO Orders (OrderID, ProductName, Quantity, Cost, OrderDate)
VALUES
(1, 'Laptop', 5, 1000.00, '2025-04-10'),
(2, 'Tablet', 15, 500.00, '2025-04-11'),
(3, 'Phone', 25, 700.00, '2025-04-12'),
(4, 'Monitor', 8, 300.00, '2025-04-13'),
(5, 'Keyboard', 20, 150.00, '2025-04-14');


SELECT * FROM Orders;
# this procedure is meant to determine if a discount would be given and what % discount 
# that customers would recieve all depending on the QUANTITY ORDERED

DROP PROCEDURE IF EXISTS GetDiscount;
DELIMITER // 
CREATE PROCEDURE GetDiscount(OrderIDInput int)
BEGIN
	declare order_quantity INT;
    declare Current_Cost  decimal (7,2);
    declare Cost_after_discount  decimal (7,2);
    
    SELECT Quantity INTO order_quantity FROM Orders 
    where OrderID = OrderIDInput;
    
    SELECT Cost INTO current_cost FROM Orders 
    where OrderID = OrderIDInput;
    
    IF order_quantity >= 20 THEN 
    set Cost_after_discount = Current_Cost- (Current_Cost * 0.2);
    
    ELSEIF order_quantity >= 10 THEN
	set Cost_after_discount = Current_Cost- (Current_Cost * 0.1);
    
    ELSE set Cost_after_discount = Current_Cost;
    
    END IF;
    
    SELECT Cost_after_discount;
    
    END //
    
    DELIMITER ;
    
    #lets use the procedure 
    
    call GetDiscount(3);
    
    
    
/*When you're working with stored procedures that use OUT parameters in MySQL, 
that 3-step method is the standard way to retrieve results from them — 
especially when calling from the MySQL console or GUI tools like MySQL Workbench.

Quick Recap of the 3-Step Pattern for OUT Parameters:
1. Declare a Session Variable
To hold the value that the procedure will output:


SET @your_var = 0;
2. Call the Procedure
Pass the session variable as the OUT argument:


CALL your_procedure_name(@your_var);
3. Retrieve the Value
Select the value from the session variable:


SELECT @your_var;

Think of it like giving the procedure a notepad, and it writes the result on that pad. 
You have to go check that pad (SELECT @var) to see what it wrote.
*/
