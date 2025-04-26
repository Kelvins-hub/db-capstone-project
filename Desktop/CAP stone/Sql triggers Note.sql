CREATE DATABASE Triggers;

USE Triggers; 

#sql trigger note
# what is an sql trigger
-- these are sets of actions avaliable in the form of a stored program, invoked when
-- an event occurs. example of these events include 
#inserting, updating and  deleting from a database.

-- triggers can also be used to enforce a constraint 
-- e.g no negative integer must be inserted
-- ------------------------------------
-- types of triggers 
-- before update and after update
-- before insert and after insert
-- before delete and after delete

-- ----------------------------------------------------------------------
/* general syntax for triggers
CREATE trigger trigger_name
(before | after)  (INSERT |UPDATE | DELETE) 
ON table_name FOR EACH ROW
Trigger_body; */

-- -------------------------------------------------------------------
/* 
Why change the delimiter?
By default, SQL statements end with a semicolon (;). But when writing a trigger, 
you're including multiple statements inside the BEGIN ... END block, 
and those inner statements also use semicolons.

To prevent MySQL from thinking the trigger definition ends too early, 
you temporarily change the delimiter to something else (like $$ or //). 
NB
this is only required in MySQL, not in other databases like PostgreSQL or SQL Server.
*/
-- -----------------------------------------------------------------------------
-- EXAMPLE OF BEFORE INSERT TRIGGER

/* 🎯 Scenario
You have a users table. You want to ensure that all emails are stored in lowercase, 
even if someone tries to insert them in uppercase or mixed case.*/

-- LETS CREATE A TABLE WHERE THE TRIGGER WOULD ACT ON 
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

DELIMITER $$

CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- Convert the email to lowercase before inserting
    SET NEW.email = LOWER(NEW.email);
END$$

DELIMITER ;

-- --------------------------------------------------------------------------
/*✅ How It Works
BEFORE INSERT means this trigger runs before a new row is inserted.

FOR EACH ROW means it runs for every new row.

NEW.email refers to the email value being inserted.

LOWER(NEW.email) ensures it’s in lowercase before it’s saved.*/
-- ---------------------------------------------------------------------------
# testing the above insert trigger

INSERT INTO users (name, email)
VALUES ('johnne', 'Josh.bush@Example.COM');
-- -------------------------
Select * from users; 
# result -- Alice	alice.smith@example.com

/* The BEFORE INSERT trigger example is indeed an example of using a trigger to
 enforce a constraint, specifically a data consistency constraint.*/
-- ----------------------------------------------------------------------------

# EXAMPLE OF AFTER INSERT 
/*
🎯 Scenario
You have a customers table and want to automatically create a welcome log entry
 in a customer_logs table after a new customer is added.*/
 
 #Table on which trigger would act
 CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE customer_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    message TEXT,
    log_time DATETIME
);

DELIMITER $$

CREATE TRIGGER after_customer_insert
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
    INSERT INTO customer_logs (customer_id, message, log_time)
    VALUES (NEW.id, CONCAT('Welcome, ', NEW.name, '!'), NOW());
END$$

DELIMITER ;

/* How It Works
AFTER INSERT runs after a new row is successfully inserted into customers.

NEW.id and NEW.name refer to the newly inserted customer.

It creates a personalized welcome message and logs it with a timestamp*/
-- ----------------------------------
#TESTING AFTER INSERT TRIGGER

INSERT INTO customers (name, email)
VALUES ('richard akada', 'richa@example.com');

SELECT * FROM customer_logs;
-- -----------------------------------------------------------------------------------
#BEFORE UPDATE TRIGGER

/*🎯 Scenario
You have a users table, and you want to automatically track any change to a 
user's email address. Before updating, you want to:

Check if the new email is different from the old one.
Convert the new email to lowercase before saving.

purpose of this trigger 
1. Enforce Lowercase Email Storage
2. Block Unnecessary Updates  */

#LETS CREATE A TABLE THAT THE TRIGGER WOULD ACT ON
CREATE TABLE users_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

# adding values to table for the sake of example 

insert into 
users_table(name, email)
values('kelvo', 'akiobobo@eg'),
	('judith', 'jubu@eg'),
    ('esther', 'cole@eg'),
    ('becky', 'agree@eg');

DELIMITER $$

CREATE TRIGGER before_user_email_update
BEFORE UPDATE ON users_table
FOR EACH ROW
BEGIN
    -- Convert email to lowercase
    SET NEW.email = LOWER(NEW.email);

    -- Optional: Prevent update if email is not actually changing
    IF OLD.email = NEW.email THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email address is unchanged.';
    END IF;
END$$

DELIMITER ;

-- ------------------------------
#🧪 Testing

UPDATE users_table
SET email = 'NEW.Email@Example.com'
WHERE id = 1;

select * from users_table;

-- -----------------------------------------------------------------------------
#EXAMPLE OF AFTER UPDATE TRIGGER

/*🎯 Scenario
You want to track changes to user email addresses. When a user's email is updated, you want to log:

The user's ID
The old email address
The new email address
The time the change occurred*/

# LETS CREATE A TABLES ON WHICH THE TRIGGER WOULD ACT
CREATE TABLE users_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE email_change_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    old_email VARCHAR(100),
    new_email VARCHAR(100),
    change_time DATETIME
);

select * from users_details;

#lets add some fake data for practise purposes
insert into users_details (name, email)
values
( 2, 'soji@gm' ),
( 3, 'nonso@gm' );
-- --------------------------------
# create trigger 
DELIMITER $$

CREATE TRIGGER after_email_update
AFTER UPDATE ON users_details
FOR EACH ROW
BEGIN
    -- Only log if the email actually changed
    IF OLD.email <> NEW.email THEN
        INSERT INTO email_change_log (user_id, old_email, new_email, change_time)
        VALUES (OLD.id, OLD.email, NEW.email, NOW());
    END IF;
END$$

DELIMITER ;

-- --------------------
# 🧪 Test It
select * from users_details;

UPDATE users_details
SET email = 'new.email@example.com'
WHERE id = 1;


 select *  from email_change_log;
 
 -- -------------------------------------------------------------------------------
 # example of BEFORE DELETE TRIGGER
 
 /*🎯 Scenario
You want to prevent deletion of users who are marked as “protected” in your database — 
for instance, admin users or system-critical accounts.*/
#drop table  if exists premiun_users;
CREATE TABLE user_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    is_protected BOOLEAN DEFAULT FALSE
);

#lets input some fake data that the trigger would act on
#TRUNCATE TABLE user_status;


insert into user_status (name, email, is_protected)
values ('kelvo', 'kio@gm', 0),
	('soji', 'soj@gm', 1),
    ('azeez', 'az@gm',0),
    ('id', 'idw@gm', 1);


select * from user_status;

#⚙️ BEFORE DELETE Trigger

DELIMITER $$

CREATE TRIGGER prevent_protected_user_delete
BEFORE DELETE ON user_status
FOR EACH ROW
BEGIN
    IF OLD.is_protected THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete a protected user.';
    END IF;
END$$

DELIMITER ;

/*
Trigger Part			Purpose
BEFORE DELETE		Runs just before a deletion occurs
FOR EACH ROW		Applies to every row being deleted
OLD.is_protected		Checks the flag of the row being deleted
SIGNAL				Aborts the deletion with a custom error message */
-- ---------------------------------------------
-- Try deleting a protected user
DELETE FROM user_status WHERE id = 1; # would work because id = 1 is not protected

DELETE FROM user_status WHERE id = 2; #would not work: becuase it is protected.

-- ----------------------------------------------------------------------------

#EXAMPLE AFTER DELETE TRIGGER

/*🎯 Scenario
You want to log deleted user records into an archive table for 
auditing purposes — for example, to know who was deleted and when.*/

-- Main users table
CREATE TABLE users_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Archive table to log deleted users
CREATE TABLE deleted_users_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    deleted_at DATETIME
);

#lets insert some fake record just so the trigger has data to act on

insert into users_data(name, email)
values ('odogbolo', 'ogi@gm'),
		('rega', 're@gm'),
        ('jogu', 'john');

select * from users_data;
-- ------------------------------------
#⚙️ AFTER DELETE Trigger
drop trigger if exists after_user_delete;

DELIMITER $$

CREATE TRIGGER after_user_delete
AFTER DELETE ON users_data
FOR EACH ROW
BEGIN
    INSERT INTO deleted_users_log (user_id, name, email, deleted_at)
    VALUES (OLD.id, OLD.name, OLD.email, NOW());
END$$

DELIMITER ;

-- --------------------
# 🧪 Test It

insert into users_data (name, email)
values ('soji', 'soj@gm'),
		('saint', 'dr@gm');

DELETE FROM users_data WHERE id = 5;

SELECT * FROM deleted_users_log;


#END OF NOTE ON TRIGGERS

 







