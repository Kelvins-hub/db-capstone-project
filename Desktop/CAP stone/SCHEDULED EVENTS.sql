create database scheduled_events_db;

use scheduled_events_db;

/*SQL SCHEDULED EVENTS
The purpose of Scheduled Events in SQL (especially in MySQL)is to automate tasks 
that would otherwise require manual executionor external scripts (like cron jobs). 
They allow your database to run SQL statements at scheduled times or intervals — kind
 of like built-in alarms that do work for you.*/
 
 #THERE ARE TWO TYPES OF SCHEDULE EVENTS
 #1. ONE TIME EVENTS
 #2. REOCCURING EVENTS
 
/*✅ One-Time Event Syntax
CREATE EVENT event_name
ON SCHEDULE AT TIMESTAMP 'YYYY-MM-DD HH:MM:SS'
DO
    sql_statement;*/
    
#lets create a table that the schedule event would act on
/*an example of a MySQL scheduled event that inserts total sales at the close of business
into a simple report table. This is a one-off event, meaning it runs only
 once at a specific time */
 
 
 -- Table to record log messages
CREATE TABLE system_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_message VARCHAR(255),
    log_time DATETIME
);

-- Enable event scheduler if it's not already enabled
SET GLOBAL event_scheduler = ON;
#The Event Scheduler is a MySQL feature that lets you schedule tasks (events)
# to run automatically at specific times or intervals

/*🔧 What This Command Does
SET GLOBAL event_scheduler = ON; turns the scheduler on at the server level.

It allows scheduled EVENTS to start running at their defined times.*/

-- Create the scheduled event
CREATE EVENT log_message_event
ON SCHEDULE AT '2025-04-24 11:58:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('Scheduled event executed', NOW());
  
  #testing
select * from system_log; #before the time, the table was empty,
select * from system_log; #running this command after  '2025-04-24 11:58:00' it updates 

#The key difference between a one-time event and a recurring event in MySQL lies in 
#how you specify the schedule one time event
#ON SCHEDULE AT 'start_date and time'
#ON SCHEDULE EVERY 1 XYZ -- FOLLOWED BY THE start 'date and time'
#STARTS '2025-04-25 00:00:00' FOLLOWED BY DO keyword

CREATE EVENT one_time_event_1
ON SCHEDULE AT '2025-05-01 08:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('One-time event executed at 8 AM', NOW());
-- ---------------------------------------------------
CREATE EVENT one_time_event_2
ON SCHEDULE AT '2025-06-15 14:30:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('One-time event executed on June 15 at 2:30 PM', NOW());
-- -------------------------------------------------------
CREATE EVENT one_time_event_3
ON SCHEDULE AT '2025-07-01 00:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('One-time event executed at midnight', NOW());

-- --------------------------------------------------------------------------------------
 
 -- Table to record sales transactions
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    amount DECIMAL(10, 2),
    sale_date DATETIME
);

-- Report table to store daily total sales
CREATE TABLE sales_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATETIME,
    total_sales DECIMAL(10, 2)
);


-- Enable event scheduler if it's not already enabled
SET GLOBAL event_scheduler = ON;

-- Create a scheduled event that runs once at 11:59 PM
CREATE EVENT insert_daily_sales_report
ON SCHEDULE AT '2025-04-24 23:59:00'
DO
  INSERT INTO sales_report (report_date, total_sales)
  SELECT NOW(), SUM(amount) 
  FROM sales 
  WHERE DATE(sale_date) = CURDATE();


-- ---------------------------------------------------------------------------------------
# re-occurring event syntax

/*CREATE EVENT event_name
ON SCHEDULE EVERY interval
DO
  -- SQL statements to execute*/
  

#1. Daily Event (Every 1 Day)
CREATE EVENT daily_event
ON SCHEDULE EVERY 1 DAY
STARTS '2025-04-25 00:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('Daily event executed', NOW());
-- -------------------------------------------------------------
#2. Hourly Event (Every 1 Hour)
CREATE EVENT hourly_event
ON SCHEDULE EVERY 1 HOUR
STARTS '2025-04-25 00:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('Hourly event executed', NOW());

-- ------------------------------------------------------------
#3. Weekly Event (Every 1 Week)
CREATE EVENT weekly_event
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-04-25 00:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('Weekly event executed', NOW());

-- ---------------------------------------------------------------
#4. Every 5 Minutes
CREATE EVENT five_minute_event
ON SCHEDULE EVERY 5 MINUTE
STARTS '2025-04-25 00:00:00'
DO
  INSERT INTO system_log (log_message, log_time)
  VALUES ('5-minute event executed', NOW());

-- ---------------------------------------------------------------------------------------

